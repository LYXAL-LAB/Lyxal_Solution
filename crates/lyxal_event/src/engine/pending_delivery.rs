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
//
// Portions of this file are derived from Danube Messaging (danube-broker/src/dispatcher/pending_delivery.rs),
// under Apache-2.0 license. Adapted for Lyxal OS by the Lyxal Development Team.

//! Machine à états du cycle de vie unitaire d'un message en vol (PendingDelivery).
//!
//! Ce composant suit le cycle de vie précis d'un message :
//! `ReadyToSend` -> `AwaitingAck` -> `WaitingToRetry` / `RetryExhausted`.
//!
//! Il s'agit d'une machine à états purement déterministe en mémoire vive,
//! sans aucune dépendance I/O, base de données ou protocole réseau.

use std::time::Duration;
use tokio::time::Instant;

/// Statut du cycle de vie d'une livraison en cours.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PendingDeliveryStatus {
    /// Prêt à être expédié vers un consommateur / handler.
    ReadyToSend,
    /// Expédié au handler, en attente de confirmation d'acquittement (ACK).
    AwaitingAck,
    /// En échec temporaire, en attente de réexpédition après expiration du backoff.
    WaitingToRetry,
    /// Échec définitif : le quota maximal de réexpéditions a été épuisé (éligible DLQ).
    RetryExhausted,
}

/// Stratégie de temporisation entre deux tentatives de réexpédition.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BackoffStrategy {
    /// Délai constant entre chaque tentative.
    Fixed,
    /// Délai doublé à chaque tentative : `base_delay * 2^(attempt - 1)`.
    Exponential,
}

/// Politique de livraison et de retry associée à une souscription ou un worker.
#[derive(Debug, Clone)]
pub struct DeliveryPolicy {
    /// Nombre maximal de tentatives autorisées avant déclaration d'épuisement.
    pub max_redelivery_count: u32,
    /// Délai maximal d'attente d'un ACK avant de considérer le message en timeout.
    pub ack_timeout: Duration,
    /// Délai de base entre deux retries consécutifs.
    pub base_redelivery_delay: Duration,
    /// Plafond maximal du délai de retry pour éviter des temps d'attente prohibitifs.
    pub max_redelivery_delay: Duration,
    /// Stratégie de backoff (Fixed ou Exponential).
    pub backoff_strategy: BackoffStrategy,
    /// Activation du Full Jitter uniforme sur le calcul du backoff.
    pub jitter: bool,
}

impl Default for DeliveryPolicy {
    fn default() -> Self {
        Self {
            max_redelivery_count: 5,
            ack_timeout: Duration::from_secs(30),
            base_redelivery_delay: Duration::from_secs(1),
            max_redelivery_delay: Duration::from_secs(300),
            backoff_strategy: BackoffStrategy::Exponential,
            jitter: false,
        }
    }
}

/// Conteneur d'un message en cours de livraison avec son historique d'état.
#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct PendingDelivery<T> {
    /// Message ou enveloppe transportée.
    pub message: T,
    /// Compteur du nombre de tentatives de livraison effectuées.
    pub delivery_attempt: u32,
    /// Horodatage de la toute première émission.
    pub first_sent_at: Instant,
    /// Horodatage de la tentative d'émission la plus récente.
    pub last_sent_at: Instant,
    /// Échéance limite avant expiration de l'attente d'ACK.
    pub ack_deadline_at: Instant,
    /// Horodatage à partir duquel le message devient éligible à une nouvelle tentative.
    pub next_redelivery_at: Instant,
    /// Dernier motif d'échec constaté (si NACK explicite ou erreur de handler).
    pub last_failure_reason: Option<String>,
    /// Identifiant du consommateur / worker actuellement assigné à cette tentative.
    pub target_consumer_id: Option<String>,
    /// Statut courant de la livraison.
    pub status: PendingDeliveryStatus,
}

impl<T> PendingDelivery<T> {
    /// Initialise un nouveau message prêt à être émis.
    pub fn new(message: T) -> Self {
        let now = Instant::now();
        Self {
            message,
            delivery_attempt: 0,
            first_sent_at: now,
            last_sent_at: now,
            ack_deadline_at: now,
            next_redelivery_at: now,
            last_failure_reason: None,
            target_consumer_id: None,
            status: PendingDeliveryStatus::ReadyToSend,
        }
    }

    /// Indique si la livraison est en attente d'un accusé de réception (ACK/NACK).
    pub fn is_awaiting_ack(&self) -> bool {
        self.status == PendingDeliveryStatus::AwaitingAck
    }

    /// Indique si le message a épuisé l'intégralité de son quota d'essais.
    pub fn is_retry_exhausted(&self) -> bool {
        self.status == PendingDeliveryStatus::RetryExhausted
    }

    /// Indique si le message est actuellement en phase d'attente de temporisation de retry.
    pub fn is_waiting_to_retry(&self) -> bool {
        self.status == PendingDeliveryStatus::WaitingToRetry
    }

    /// Indique si le message est prêt à être expédié ou réexpédié à l'instant `now`.
    pub fn is_retry_ready(&self, now: Instant) -> bool {
        matches!(
            self.status,
            PendingDeliveryStatus::ReadyToSend | PendingDeliveryStatus::WaitingToRetry
        ) && now >= self.next_redelivery_at
    }

    /// Vérifie si le délai d'attente de l'ACK a expiré à l'instant `now`.
    pub fn ack_timed_out(&self, now: Instant) -> bool {
        self.status == PendingDeliveryStatus::AwaitingAck && now >= self.ack_deadline_at
    }

    /// Enregistre une tentative d'expédition vers un consommateur donné.
    ///
    /// Fait passer le statut à `AwaitingAck`, incrémente le compteur de tentatives,
    /// et configure l'échéance `ack_deadline_at = now + ack_timeout`.
    pub fn on_send_attempt(&mut self, consumer_id: impl Into<String>, ack_timeout: Duration) {
        let now = Instant::now();
        if self.delivery_attempt == 0 {
            self.first_sent_at = now;
        }
        self.delivery_attempt = self.delivery_attempt.saturating_add(1);
        self.last_sent_at = now;
        self.ack_deadline_at = now + ack_timeout;
        self.next_redelivery_at = now;
        self.target_consumer_id = Some(consumer_id.into());
        self.status = PendingDeliveryStatus::AwaitingAck;
    }

    /// Calcule la durée de temporisation avant la prochaine tentative.
    pub fn compute_redelivery_delay(&self, policy: &DeliveryPolicy) -> Duration {
        let base_delay = policy.base_redelivery_delay;

        let computed = match policy.backoff_strategy {
            BackoffStrategy::Fixed => base_delay,
            BackoffStrategy::Exponential => {
                let attempt = self.delivery_attempt.max(1);
                let exponent = attempt.saturating_sub(1).min(62);
                let factor = 1u64.checked_shl(exponent).unwrap_or(u64::MAX);
                base_delay.saturating_mul(factor as u32)
            }
        };

        let capped = computed.min(policy.max_redelivery_delay);

        if policy.jitter {
            let nanos = capped.as_nanos();
            let nanos_u64 = u64::try_from(nanos).unwrap_or(u64::MAX);
            if nanos_u64 == 0 {
                Duration::ZERO
            } else {
                Duration::from_nanos(fastrand::u64(0..=nanos_u64))
            }
        } else {
            capped
        }
    }

    /// Applique un refus explicite (NACK) ou un échec d'exécution du handler.
    ///
    /// Si le quota `max_redelivery_count` est atteint ou dépassé, la livraison
    /// bascule en `RetryExhausted`. Sinon, elle bascule en `WaitingToRetry`.
    pub fn on_nack(&mut self, policy: &DeliveryPolicy, reason: Option<String>) {
        self.last_failure_reason = reason;
        let now = Instant::now();

        if self.delivery_attempt >= policy.max_redelivery_count {
            self.status = PendingDeliveryStatus::RetryExhausted;
        } else {
            let delay = self.compute_redelivery_delay(policy);
            self.next_redelivery_at = now + delay;
            self.status = PendingDeliveryStatus::WaitingToRetry;
        }
    }

    /// Traite l'expiration du délai d'attente d'ACK.
    pub fn on_ack_timeout(&mut self, policy: &DeliveryPolicy) {
        self.on_nack(policy, Some("ACK timeout expired".to_string()));
    }

    /// Force l'éligibilité immédiate à une réexpédition (sans attendre le backoff restant).
    ///
    /// Utilisé lors des reconnexions ou réattributions de workers.
    pub fn schedule_retry_now(&mut self, reason: Option<String>) {
        if let Some(r) = reason {
            self.last_failure_reason = Some(r);
        }
        self.next_redelivery_at = Instant::now();
        self.status = PendingDeliveryStatus::WaitingToRetry;
    }

    /// Force l'épuisement immédiat du quota de tentatives (erreur terminale).
    pub fn force_exhaust(&mut self, reason: Option<String>) {
        self.last_failure_reason = reason;
        self.status = PendingDeliveryStatus::RetryExhausted;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pending_delivery_lifecycle_nominal() {
        let mut pd = PendingDelivery::new("message_payload".to_string());
        assert_eq!(pd.status, PendingDeliveryStatus::ReadyToSend);
        assert_eq!(pd.delivery_attempt, 0);

        let now = Instant::now();
        assert!(pd.is_retry_ready(now));
        assert!(!pd.is_awaiting_ack());

        // 1ère émission
        pd.on_send_attempt("worker_alpha", Duration::from_secs(10));
        assert_eq!(pd.status, PendingDeliveryStatus::AwaitingAck);
        assert_eq!(pd.delivery_attempt, 1);
        assert_eq!(pd.target_consumer_id.as_deref(), Some("worker_alpha"));
        assert!(pd.is_awaiting_ack());
        assert!(!pd.is_retry_ready(now));
    }

    #[test]
    fn test_pending_delivery_fixed_retry() {
        let mut pd = PendingDelivery::new("msg");
        let policy = DeliveryPolicy {
            max_redelivery_count: 3,
            ack_timeout: Duration::from_secs(5),
            base_redelivery_delay: Duration::from_millis(50),
            max_redelivery_delay: Duration::from_secs(10),
            backoff_strategy: BackoffStrategy::Fixed,
            jitter: false,
        };

        pd.on_send_attempt("w1", policy.ack_timeout);
        pd.on_nack(&policy, Some("handler error".to_string()));

        assert_eq!(pd.status, PendingDeliveryStatus::WaitingToRetry);
        assert_eq!(pd.last_failure_reason.as_deref(), Some("handler error"));
        assert_eq!(pd.compute_redelivery_delay(&policy), Duration::from_millis(50));
    }

    #[test]
    fn test_pending_delivery_exponential_retry() {
        let mut pd = PendingDelivery::new("msg");
        let policy = DeliveryPolicy {
            max_redelivery_count: 5,
            ack_timeout: Duration::from_secs(5),
            base_redelivery_delay: Duration::from_millis(100),
            max_redelivery_delay: Duration::from_secs(10),
            backoff_strategy: BackoffStrategy::Exponential,
            jitter: false,
        };

        // Tentative 1
        pd.on_send_attempt("w1", policy.ack_timeout);
        assert_eq!(pd.compute_redelivery_delay(&policy), Duration::from_millis(100)); // 100 * 2^0

        // Tentative 2
        pd.on_send_attempt("w1", policy.ack_timeout);
        assert_eq!(pd.compute_redelivery_delay(&policy), Duration::from_millis(200)); // 100 * 2^1

        // Tentative 3
        pd.on_send_attempt("w1", policy.ack_timeout);
        assert_eq!(pd.compute_redelivery_delay(&policy), Duration::from_millis(400)); // 100 * 2^2
    }

    #[test]
    fn test_pending_delivery_exhaustion() {
        let mut pd = PendingDelivery::new("msg");
        let policy = DeliveryPolicy {
            max_redelivery_count: 2,
            ack_timeout: Duration::from_secs(5),
            base_redelivery_delay: Duration::from_millis(10),
            max_redelivery_delay: Duration::from_secs(1),
            backoff_strategy: BackoffStrategy::Fixed,
            jitter: false,
        };

        // Essai 1
        pd.on_send_attempt("w1", policy.ack_timeout);
        pd.on_nack(&policy, None);
        assert_eq!(pd.status, PendingDeliveryStatus::WaitingToRetry);
        assert!(!pd.is_retry_exhausted());

        // Essai 2 (limite atteinte)
        pd.on_send_attempt("w1", policy.ack_timeout);
        pd.on_nack(&policy, Some("fatal".to_string()));
        assert_eq!(pd.status, PendingDeliveryStatus::RetryExhausted);
        assert!(pd.is_retry_exhausted());
    }

    #[test]
    fn test_pending_delivery_ack_timeout() {
        let mut pd = PendingDelivery::new("msg");
        let policy = DeliveryPolicy {
            max_redelivery_count: 3,
            ack_timeout: Duration::from_millis(50),
            base_redelivery_delay: Duration::from_millis(10),
            max_redelivery_delay: Duration::from_secs(1),
            backoff_strategy: BackoffStrategy::Fixed,
            jitter: false,
        };

        pd.on_send_attempt("w1", policy.ack_timeout);
        let start = Instant::now();
        assert!(!pd.ack_timed_out(start));

        let future = start + Duration::from_millis(60);
        assert!(pd.ack_timed_out(future));

        pd.on_ack_timeout(&policy);
        assert_eq!(pd.status, PendingDeliveryStatus::WaitingToRetry);
        assert_eq!(pd.last_failure_reason.as_deref(), Some("ACK timeout expired"));
    }

    #[test]
    fn test_pending_delivery_schedule_retry_now() {
        let mut pd = PendingDelivery::new("msg");
        let policy = DeliveryPolicy::default();

        pd.on_send_attempt("w1", policy.ack_timeout);
        pd.on_nack(&policy, None);

        // Forcer le retry immédiat
        pd.schedule_retry_now(Some("worker reconnect".to_string()));
        assert_eq!(pd.status, PendingDeliveryStatus::WaitingToRetry);
        assert!(pd.is_retry_ready(Instant::now()));
        assert_eq!(pd.last_failure_reason.as_deref(), Some("worker reconnect"));
    }
}

