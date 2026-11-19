//! Accès commun aux baux du runtime (`fn::runtime_lease_*`, table `runtime_lease`). Les
//! échéances sont calculées par la base ; les gestionnaires de baux de migration,
//! d'installation et d'élection (`leader`) s'appuient sur ces appels.

use crate::error::RuntimeError;
use crate::lock::node_id::NodeId;
use lyxal_surreal::{LyxalSurrealCall, LyxalSurrealError, SurrealValue};
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

/// Nature d'un bail.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum LeaseKind {
    Migration,
    Installation,
    Leader,
}

impl LeaseKind {
    fn as_str(self) -> &'static str {
        match self {
            Self::Migration => "migration",
            Self::Installation => "installation",
            Self::Leader => "leader",
        }
    }
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseAcquireParams {
    kind: String,
    key: String,
    node_id: String,
    ttl_seconds: i64,
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseRenewParams {
    kind: String,
    key: String,
    node_id: String,
    generation: i64,
    ttl_seconds: i64,
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseReleaseParams {
    kind: String,
    key: String,
    node_id: String,
    generation: i64,
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseGetParams {
    kind: String,
    key: String,
}

/// Bail tel que stocké (instants en secondes Unix, heure de la base).
#[derive(Debug, Clone, SurrealValue)]
pub(crate) struct LeaseRow {
    pub owner_node_id: String,
    pub generation: i64,
    pub acquired_at: i64,
    pub renewed_at: i64,
    pub expires_at: i64,
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseAcquireResult {
    outcome: String,
    lease: LeaseRow,
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseRenewResult {
    renewed: bool,
    #[surreal(default)]
    lease: Option<LeaseRow>,
}

#[derive(Debug, Clone, SurrealValue)]
struct LeaseReleaseResult {
    released: bool,
}

/// Issue d'une prise de bail.
#[derive(Debug, Clone)]
pub(crate) enum LeaseOutcome {
    Acquired(LeaseRow),
    Recovered(LeaseRow),
    AlreadyOwned(LeaseRow),
    HeldByOther(LeaseRow),
}

/// Client des fonctions de bail.
pub(crate) struct LeaseStore {
    client: Surreal<Any>,
}

impl LyxalSurrealCall for LeaseStore {
    fn surreal_client(&self) -> &Surreal<Any> {
        &self.client
    }
}

/// Nombre maximal de rejeux d'un appel interrompu par un conflit d'écriture transitoire.
const MAX_CONFLICT_RETRIES: u32 = 8;

/// Attente aléatoire croissante avant un rejeu, pour désynchroniser les nœuds concurrents.
async fn conflict_backoff(attempt: u32) {
    let upper = 10 + 20 * u64::from(attempt);
    // Les bits de poids faible d'un UUID v7 sont tirés au hasard
    let jitter = (uuid::Uuid::now_v7().as_u128() as u64) % upper;
    tokio::time::sleep(Duration::from_millis(5 + jitter)).await;
}

fn ttl_seconds(ttl: Duration) -> i64 {
    i64::try_from(ttl.as_secs().max(1))
        .unwrap_or(86_400)
        .min(86_400)
}

fn generation(value: u64) -> Result<i64, RuntimeError> {
    i64::try_from(value).map_err(|_| RuntimeError::StoreFailed {
        operation: "runtime_lease",
        message: format!("génération hors bornes : {value}"),
    })
}

impl LeaseStore {
    pub(crate) fn new(client: Surreal<Any>) -> Self {
        Self { client }
    }

    /// Appel d'une fonction de bail, rejoué en cas de conflit d'écriture transitoire : sur un
    /// serveur SurrealDB, deux nœuds qui écrivent le même bail en même temps (deux hôtes qui
    /// démarrent ensemble, un concurrent qui demande le bail pendant que son détenteur le
    /// prolonge) font échouer l'une des deux transactions. Le rejeu lit l'état validé par l'autre
    /// et rend la réponse ordinaire (bail détenu par un autre nœud, prolongé, libéré).
    async fn call_with_conflict_retry<T, P>(
        &self,
        function: &'static str,
        params: P,
    ) -> Result<T, LyxalSurrealError>
    where
        T: SurrealValue + Send,
        P: SurrealValue + Clone + Send + 'static,
    {
        let mut attempt = 0;
        loop {
            match self.call_fn(function, params.clone()).await {
                Err(e) if e.is_transient_conflict() && attempt < MAX_CONFLICT_RETRIES => {
                    attempt += 1;
                    conflict_backoff(attempt).await;
                }
                other => return other,
            }
        }
    }

    pub(crate) async fn acquire(
        &self,
        kind: LeaseKind,
        key: &str,
        node_id: &NodeId,
        ttl: Duration,
    ) -> Result<LeaseOutcome, LyxalSurrealError> {
        let result: LeaseAcquireResult = self
            .call_with_conflict_retry(
                "runtime_lease_acquire",
                LeaseAcquireParams {
                    kind: kind.as_str().to_string(),
                    key: key.to_string(),
                    node_id: node_id.to_string(),
                    ttl_seconds: ttl_seconds(ttl),
                },
            )
            .await?;
        Ok(match result.outcome.as_str() {
            "acquired" => LeaseOutcome::Acquired(result.lease),
            "recovered" => LeaseOutcome::Recovered(result.lease),
            "already_owned" => LeaseOutcome::AlreadyOwned(result.lease),
            _ => LeaseOutcome::HeldByOther(result.lease),
        })
    }

    /// Prolonge le bail ; `None` s'il n'est plus détenu par ce nœud dans cette génération.
    pub(crate) async fn renew(
        &self,
        kind: LeaseKind,
        key: &str,
        node_id: &NodeId,
        lease_generation: u64,
        ttl: Duration,
    ) -> Result<Option<LeaseRow>, RuntimeError> {
        let result: LeaseRenewResult = self
            .call_with_conflict_retry(
                "runtime_lease_renew",
                LeaseRenewParams {
                    kind: kind.as_str().to_string(),
                    key: key.to_string(),
                    node_id: node_id.to_string(),
                    generation: generation(lease_generation)?,
                    ttl_seconds: ttl_seconds(ttl),
                },
            )
            .await
            .map_err(|e| RuntimeError::StoreFailed {
                operation: "runtime_lease_renew",
                message: e.to_string(),
            })?;
        Ok(if result.renewed { result.lease } else { None })
    }

    /// Libère le bail ; `false` s'il n'était plus détenu par ce nœud dans cette génération.
    pub(crate) async fn release(
        &self,
        kind: LeaseKind,
        key: &str,
        node_id: &NodeId,
        lease_generation: u64,
    ) -> Result<bool, RuntimeError> {
        let result: LeaseReleaseResult = self
            .call_with_conflict_retry(
                "runtime_lease_release",
                LeaseReleaseParams {
                    kind: kind.as_str().to_string(),
                    key: key.to_string(),
                    node_id: node_id.to_string(),
                    generation: generation(lease_generation)?,
                },
            )
            .await
            .map_err(|e| RuntimeError::StoreFailed {
                operation: "runtime_lease_release",
                message: e.to_string(),
            })?;
        Ok(result.released)
    }

    /// Bail actif (détenu et non expiré à l'heure de la base).
    pub(crate) async fn get(
        &self,
        kind: LeaseKind,
        key: &str,
    ) -> Result<Option<LeaseRow>, RuntimeError> {
        self.call_fn(
            "runtime_lease_get",
            LeaseGetParams {
                kind: kind.as_str().to_string(),
                key: key.to_string(),
            },
        )
        .await
        .map_err(|e| RuntimeError::StoreFailed {
            operation: "runtime_lease_get",
            message: e.to_string(),
        })
    }
}

/// Instant (secondes Unix) d'un bail, toujours positif quand il vient de la base.
pub(crate) fn instant(value: i64) -> u64 {
    u64::try_from(value).unwrap_or_default()
}
