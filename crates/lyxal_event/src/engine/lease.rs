// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

//! Gestionnaire de bail distribué et suivi de leadership (`OutboxLeaseManager`).
//!
//! Ce composant coordonne l'exclusivité d'exécution du flux de distribution outbox
//! sur SurrealDB au moyen d'un bail distribué avec génération monotone stricte.
//!
//! # Invariants de Sûreté
//! - Le leadership et la génération active sont systématiquement confirmés par la fonction SurrealQL
//!   durable `fn::event_lease_acquire` et `fn::event_lease_renew`.
//! - Dès qu'un renouvellement échoue ou qu'un conflit de fencing est détecté, le [`CancellationToken`]
//!   local est immédiatement déclenché pour interrompre tout traitement ou dispatching en vol.
//! - Un conflit de fencing n'est JAMAIS rejoué aveuglément.

use async_trait::async_trait;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError};
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use thiserror::Error;
use tokio_util::sync::CancellationToken;
use tracing::{info, warn};

use super::dto::{
    LeaseAcquireParams, LeaseAcquireResult, LeaseReleaseParams, LeaseReleaseResult,
    LeaseRenewParams, LeaseRenewResult,
};
use super::progress::{conflict_backoff, is_transient_conflict, MAX_CONFLICT_RETRIES};

/// Erreurs liées à la gestion du bail distribué.
#[derive(Debug, Error)]
pub enum LeaseError {
    /// Erreur de transport ou d'exécution SurrealDB.
    #[error("Erreur SurrealDB lors de l'opération de bail: {0}")]
    Surreal(Box<LyxalSurrealError>),
}

impl From<LyxalSurrealError> for LeaseError {
    fn from(err: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(err))
    }
}

/// Gestionnaire de bail distribué pour le streaming outbox de Lyxal OS.
pub struct OutboxLeaseManager {
    client: Surreal<Any>,
    node_id: String,
    ttl: Duration,
    pub(crate) generation: Arc<AtomicU64>,
    pub(crate) is_leader: Arc<AtomicBool>,
    /// Jeton du mandat de leader en cours : annulé à la perte du bail, remplacé par un jeton
    /// neuf à chaque nouvelle acquisition (un jeton annulé ne peut pas être réarmé).
    cancellation: std::sync::Mutex<CancellationToken>,
}

#[async_trait]
impl LyxalSurrealCall for OutboxLeaseManager {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

impl OutboxLeaseManager {
    /// Crée une nouvelle instance du gestionnaire de bail.
    pub fn new(client: Surreal<Any>, node_id: impl Into<String>, ttl: Duration) -> Self {
        Self {
            client,
            node_id: node_id.into(),
            ttl,
            generation: Arc::new(AtomicU64::new(0)),
            is_leader: Arc::new(AtomicBool::new(false)),
            cancellation: std::sync::Mutex::new(CancellationToken::new()),
        }
    }

    /// Configure l'état de leadership pour les tests d'intégration in-process.
    #[doc(hidden)]
    pub fn set_leader_for_test(&self, is_leader: bool, generation: u64) {
        self.is_leader.store(is_leader, Ordering::SeqCst);
        self.generation.store(generation, Ordering::SeqCst);
    }

    /// Identifiant unique du nœud local.
    pub fn node_id(&self) -> &str {
        &self.node_id
    }

    /// Numéro de génération actif du leader courant (0 si inactif).
    pub fn current_generation(&self) -> u64 {
        self.generation.load(Ordering::SeqCst)
    }

    /// Indique si ce nœud détient actuellement le bail actif.
    pub fn is_leader(&self) -> bool {
        self.is_leader.load(Ordering::SeqCst) && !self.cancellation_token().is_cancelled()
    }

    /// Jeton d'annulation associé à la validité du leadership de ce nœud.
    pub fn cancellation_token(&self) -> CancellationToken {
        self.cancellation
            .lock()
            .unwrap_or_else(std::sync::PoisonError::into_inner)
            .clone()
    }

    /// Tente d'acquérir le leadership via la fonction SurrealQL canonique `fn::event_lease_acquire`.
    pub async fn acquire_lease(&self) -> Result<bool, LeaseError> {
        let params = LeaseAcquireParams {
            node_id: self.node_id.clone(),
            ttl_seconds: self.ttl.as_secs().max(1),
        };

        let result: LeaseAcquireResult = self.call_fn("event_lease_acquire", params).await?;

        if result.acquired {
            self.generation.store(result.generation, Ordering::SeqCst);
            self.is_leader.store(true, Ordering::SeqCst);
            info!(
                node_id = %self.node_id,
                generation = result.generation,
                "Bail de streaming outbox acquis avec succès"
            );
            Ok(true)
        } else {
            self.is_leader.store(false, Ordering::SeqCst);
            warn!(
                node_id = %self.node_id,
                current_owner = %result.owner_node_id,
                current_generation = result.generation,
                "Bail de streaming outbox non acquis (détenu par un autre nœud actif)"
            );
            Ok(false)
        }
    }

    /// Renouvelle le TTL du bail actif via la fonction SurrealQL canonique `fn::event_lease_renew`.
    ///
    /// En cas d'échec ou de perte du bail, déclenche immédiatement l'annulation locale.
    pub async fn renew_lease(&self) -> Result<bool, LeaseError> {
        if !self.is_leader.load(Ordering::SeqCst) {
            return Ok(false);
        }

        let current_gen = self.current_generation();
        let params = LeaseRenewParams {
            node_id: self.node_id.clone(),
            generation: current_gen,
            ttl_seconds: self.ttl.as_secs().max(1),
        };

        let res: Result<LeaseRenewResult, LyxalSurrealError> = self
            .call_with_conflict_retry("event_lease_renew", params)
            .await;

        match res {
            Ok(result) if result.renewed => Ok(true),
            Ok(_) => {
                // Le bail a été perdu ou supplanté
                self.handle_lease_lost(current_gen);
                Ok(false)
            }
            Err(e) => {
                // Erreur SurrealQL ou réseau : si c'est un conflit de fencing, perte immédiate
                self.handle_lease_lost(current_gen);
                Err(LeaseError::Surreal(Box::new(e)))
            }
        }
    }

    /// Libère volontairement le bail via la fonction SurrealQL canonique `fn::event_lease_release`.
    pub async fn release_lease(&self) -> Result<bool, LeaseError> {
        let current_gen = self.current_generation();
        if current_gen == 0 {
            return Ok(false);
        }

        let params = LeaseReleaseParams {
            node_id: self.node_id.clone(),
            generation: current_gen,
        };

        let result: LeaseReleaseResult = self
            .call_with_conflict_retry("event_lease_release", params)
            .await?;
        self.is_leader.store(false, Ordering::SeqCst);
        self.cancellation_token().cancel();

        info!(
            node_id = %self.node_id,
            generation = current_gen,
            released = result.released,
            "Bail de streaming outbox libéré formellement"
        );
        Ok(result.released)
    }

    /// Appel SurrealQL rejoué en cas de conflit d'écriture transitoire (bail partagé par
    /// plusieurs nœuds qui tentent tous de l'écrire).
    async fn call_with_conflict_retry<T, P>(
        &self,
        function: &'static str,
        params: P,
    ) -> Result<T, LyxalSurrealError>
    where
        T: lyxal_surreal::SurrealValue + Send,
        P: lyxal_surreal::SurrealValue + Clone + Send + 'static,
    {
        let mut attempt = 0;
        loop {
            match self.call_fn(function, params.clone()).await {
                Err(e) if is_transient_conflict(&e) && attempt < MAX_CONFLICT_RETRIES => {
                    attempt += 1;
                    conflict_backoff(attempt).await;
                }
                other => return other,
            }
        }
    }

    fn handle_lease_lost(&self, generation: u64) {
        self.is_leader.store(false, Ordering::SeqCst);
        self.cancellation_token().cancel();
        warn!(
            node_id = %self.node_id,
            generation,
            "Perte de leadership détectée ! Jeton d'annulation local déclenché."
        );
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_lease_manager_initial_state() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let manager = OutboxLeaseManager::new(client, "test_node_1", Duration::from_secs(5));

        assert_eq!(manager.node_id(), "test_node_1");
        assert_eq!(manager.current_generation(), 0);
        assert!(!manager.is_leader());
        assert!(!manager.cancellation_token().is_cancelled());
    }

    #[tokio::test]
    async fn test_lease_manager_handle_lease_lost() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let manager = OutboxLeaseManager::new(client, "test_node_1", Duration::from_secs(5));

        manager.is_leader.store(true, Ordering::SeqCst);
        manager.generation.store(42, Ordering::SeqCst);
        assert!(manager.is_leader());

        manager.handle_lease_lost(42);
        assert!(!manager.is_leader());
        assert!(manager.cancellation_token().is_cancelled());
    }

    #[tokio::test]
    async fn test_lease_manager_cancellation_propagation() {
        let client = surrealdb::engine::any::connect("mem://").await.unwrap();
        let manager = OutboxLeaseManager::new(client, "test_node_1", Duration::from_secs(5));
        let cancel = manager.cancellation_token();

        assert!(!cancel.is_cancelled());
        manager.handle_lease_lost(1);
        assert!(cancel.is_cancelled());
    }
}
