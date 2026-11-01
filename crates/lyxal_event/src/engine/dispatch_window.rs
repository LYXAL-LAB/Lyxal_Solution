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
// Portions of this file are derived from Danube Messaging (danube-broker/src/dispatcher/dispatch_window.rs),
// under Apache-2.0 license. Adapted for Lyxal OS by the Lyxal Development Team.

//! Fenêtre de dispatching pipelinée avec suivi de curseur contigu sûr (`DispatchWindow`).
//!
//! # Invariant fondamental du `safe_cursor`
//!
//! Le `safe_cursor` est le plus grand offset/séquence $S$ pour lequel **TOUS les offsets $\le S$
//! ont été confirmés (soit ACKés, soit skippés/résolus en Dead-Letter Queue)**.
//!
//! Cet invariant garantit que l'autorité de persistance ne committe jamais un curseur sautant
//! par-dessus des messages non acquittés, empêchant mathématiquement toute perte de message
//! en cas de crash et de redémarrage.
//!
//! Exemple :
//! ```text
//!   Dispatched : [10, 11, 12, 13, 14]
//!   ACK reçus  : {10, 12, 14}          (11 est toujours en vol ou en retry)
//!   safe_cursor: Some(10)              (10 est le dernier contigu depuis le début)
//!
//!   Puis ACK de 11 :
//!   ACK reçus  : {10, 11, 12, 14}
//!   safe_cursor: Some(12)              (10, 11, 12 sont contigus ; 13 bloque encore)
//! ```

use std::collections::{BTreeMap, BTreeSet};
use tokio::time::Instant;

use super::pending_delivery::{DeliveryPolicy, PendingDelivery};

/// Erreur survenue lors des opérations de la fenêtre de dispatching.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DispatchWindowError {
    /// La fenêtre est pleine (capacité `max_unacked` atteinte).
    CapacityExceeded { current: usize, max: usize },
    /// L'offset proposé est inférieur ou égal au `safe_cursor` déjà persisté.
    OffsetAlreadyCommitted { offset: u64, safe_cursor: u64 },
    /// L'offset est déjà présent en vol dans la fenêtre.
    DuplicateInFlightOffset(u64),
}

/// Résultat du traitement d'un accusé de réception (ACK).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AckOutcome {
    /// L'ACK a été pris en compte et a fait avancer le curseur contigu sûr.
    Advanced { safe_cursor: u64 },
    /// L'ACK a été enregistré en vol, mais le curseur reste bloqué par un trou amont.
    Accepted { current_safe_cursor: Option<u64> },
    /// L'ACK est un duplicata (l'offset avait déjà été acquitté ou skippé).
    DuplicateAck(u64),
    /// L'ACK cible un offset inconnu (jamais dispatché dans cette fenêtre).
    UnknownOffset(u64),
}

/// Fenêtre de dispatching pipelinée avec suivi de progression contiguë.
#[allow(dead_code)]
pub struct DispatchWindow<T> {
    /// Messages expédiés et en attente d'ACK, indexés par offset / séquence.
    in_flight: BTreeMap<u64, PendingDelivery<T>>,

    /// Ensemble des offsets déjà acquittés mais en attente de rattrapage contigu.
    acked_offsets: BTreeSet<u64>,

    /// Plus grand offset où tous les offsets <= cette valeur sont certifiés ACKés ou skippés.
    safe_cursor: Option<u64>,

    /// Tout premier offset enregistré dans cette fenêtre (point de départ de la contiguïté).
    first_offset: Option<u64>,

    /// Capacité maximale de messages simultanés en vol (contrôle de flux / backpressure).
    max_unacked: usize,
}

impl<T> DispatchWindow<T> {
    /// Crée une nouvelle fenêtre de dispatching avec la capacité maximale de messages en vol.
    pub fn new(max_unacked: usize) -> Self {
        Self {
            in_flight: BTreeMap::new(),
            acked_offsets: BTreeSet::new(),
            safe_cursor: None,
            first_offset: None,
            max_unacked: max_unacked.max(1),
        }
    }

    /// Crée une fenêtre en restaurant un `safe_cursor` préalablement persisté.
    pub fn with_initial_cursor(max_unacked: usize, initial_cursor: u64) -> Self {
        Self {
            in_flight: BTreeMap::new(),
            acked_offsets: BTreeSet::new(),
            safe_cursor: Some(initial_cursor),
            first_offset: initial_cursor.checked_add(1),
            max_unacked: max_unacked.max(1),
        }
    }

    /// Indique si la fenêtre dispose de capacité disponible pour expédier de nouveaux messages.
    pub fn has_capacity(&self) -> bool {
        self.in_flight.len() < self.max_unacked
    }

    /// Nombre de messages actuellement en vol (en attente d'ACK ou de retry).
    pub fn in_flight_count(&self) -> usize {
        self.in_flight.len()
    }

    /// Capacité maximale configurée.
    pub fn max_capacity(&self) -> usize {
        self.max_unacked
    }

    /// Retourne la valeur actuelle du curseur contigu sûr (`safe_cursor`).
    pub fn safe_cursor(&self) -> Option<u64> {
        self.safe_cursor
    }

    /// Indique si la fenêtre est entièrement vide (aucun message en vol).
    pub fn is_empty(&self) -> bool {
        self.in_flight.is_empty()
    }

    /// Retourne l'offset le plus élevé dispatché ou acquitté dans la fenêtre.
    pub fn highest_dispatched_offset(&self) -> Option<u64> {
        let last_in_flight = self.in_flight.keys().next_back().copied();
        match (last_in_flight, self.safe_cursor) {
            (Some(inf), Some(sc)) => Some(inf.max(sc)),
            (Some(inf), None) => Some(inf),
            (None, Some(sc)) => Some(sc),
            (None, None) => None,
        }
    }

    /// Enregistre l'expédition d'un nouveau message sous un offset donné.
    pub fn mark_dispatched(
        &mut self,
        offset: u64,
        delivery: PendingDelivery<T>,
    ) -> Result<(), DispatchWindowError> {
        if self.in_flight.len() >= self.max_unacked {
            return Err(DispatchWindowError::CapacityExceeded {
                current: self.in_flight.len(),
                max: self.max_unacked,
            });
        }

        if let Some(sc) = self.safe_cursor {
            if offset <= sc {
                return Err(DispatchWindowError::OffsetAlreadyCommitted {
                    offset,
                    safe_cursor: sc,
                });
            }
        }

        if self.in_flight.contains_key(&offset) {
            return Err(DispatchWindowError::DuplicateInFlightOffset(offset));
        }

        if self.first_offset.is_none() {
            self.first_offset = Some(offset);
        }

        self.in_flight.insert(offset, delivery);
        Ok(())
    }

    /// Traite un acquittement positif (ACK) reçu pour un offset.
    ///
    /// Retire le message des messages en vol, l'ajoute aux offsets validés,
    /// et tente d'avancer le `safe_cursor` contigu.
    pub fn on_ack(&mut self, offset: u64) -> AckOutcome {
        if self.in_flight.remove(&offset).is_some() {
            self.acked_offsets.insert(offset);
            if let Some(new_cursor) = self.advance_safe_cursor() {
                AckOutcome::Advanced {
                    safe_cursor: new_cursor,
                }
            } else {
                AckOutcome::Accepted {
                    current_safe_cursor: self.safe_cursor,
                }
            }
        } else if self.acked_offsets.contains(&offset) {
            AckOutcome::DuplicateAck(offset)
        } else if let Some(sc) = self.safe_cursor {
            if offset <= sc {
                AckOutcome::DuplicateAck(offset)
            } else {
                AckOutcome::UnknownOffset(offset)
            }
        } else {
            AckOutcome::UnknownOffset(offset)
        }
    }

    /// Traite un message résolu comme poison (skippé ou routé vers la DLQ).
    ///
    /// Ce traitement est équivalent à un acquittement au niveau du curseur :
    /// le message ne doit plus bloquer la progression séquentielle.
    pub fn on_skipped(&mut self, offset: u64) -> Option<u64> {
        self.in_flight.remove(&offset);
        if self.first_offset.is_none() {
            self.first_offset = Some(offset);
        }
        self.acked_offsets.insert(offset);
        self.advance_safe_cursor()
    }

    /// Traite un refus explicite (NACK) pour un offset donné.
    ///
    /// Retourne `true` si l'offset était présent en vol et a été mis à jour.
    pub fn on_nack(
        &mut self,
        offset: u64,
        policy: &DeliveryPolicy,
        reason: Option<String>,
    ) -> bool {
        if let Some(pending) = self.in_flight.get_mut(&offset) {
            pending.on_nack(policy, reason);
            true
        } else {
            false
        }
    }

    /// Récupère une référence mutable sur un message en vol.
    pub fn get_mut(&mut self, offset: u64) -> Option<&mut PendingDelivery<T>> {
        self.in_flight.get_mut(&offset)
    }

    /// Récupère une référence en lecture sur un message en vol.
    pub fn get(&self, offset: u64) -> Option<&PendingDelivery<T>> {
        self.in_flight.get(&offset)
    }

    /// Collecte les offsets de tous les messages dont le délai d'ACK est expiré à `now`.
    pub fn collect_ack_timed_out(&self, now: Instant) -> Vec<u64> {
        self.in_flight
            .iter()
            .filter(|(_, d)| d.ack_timed_out(now))
            .map(|(off, _)| *off)
            .collect()
    }

    /// Collecte les offsets de tous les messages prêts à être réexpédiés à `now`.
    pub fn collect_retry_ready(&self, now: Instant) -> Vec<u64> {
        self.in_flight
            .iter()
            .filter(|(_, d)| d.is_retry_ready(now))
            .map(|(off, _)| *off)
            .collect()
    }

    /// Collecte les offsets de tous les messages ayant épuisé leur quota d'essais.
    pub fn collect_retry_exhausted(&self) -> Vec<u64> {
        self.in_flight
            .iter()
            .filter(|(_, d)| d.is_retry_exhausted())
            .map(|(off, _)| *off)
            .collect()
    }

    /// Force la réexpédition immédiate de tous les messages assignés à un worker spécifique.
    ///
    /// Utilisé lors de la déconnexion ou du crash d'un worker pour réassigner
    /// immédiatement ses messages orphelins aux workers sains.
    pub fn force_retry_for_consumer(&mut self, consumer_id: &str, reason: Option<String>) {
        for pending in self.in_flight.values_mut() {
            if pending.target_consumer_id.as_deref() == Some(consumer_id)
                && !pending.is_retry_exhausted()
            {
                pending.schedule_retry_now(reason.clone());
            }
        }
    }

    /// Fait avancer le `safe_cursor` tant qu'il existe des offsets contigus validés.
    ///
    /// L'algorithme part de `safe_cursor + 1` (ou `first_offset`) et dépile
    /// successivement `acked_offsets` tant que la séquence est continue.
    fn advance_safe_cursor(&mut self) -> Option<u64> {
        let start = match self.safe_cursor {
            Some(c) => c.checked_add(1)?,
            None => self.first_offset?,
        };

        let mut cursor = start;
        let mut advanced = false;

        while self.acked_offsets.remove(&cursor) {
            self.safe_cursor = Some(cursor);
            match cursor.checked_add(1) {
                Some(next) => cursor = next,
                None => {
                    advanced = true;
                    break;
                }
            }
            advanced = true;
        }

        if advanced {
            self.safe_cursor
        } else {
            None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    fn create_test_delivery(payload: &str) -> PendingDelivery<String> {
        PendingDelivery::new(payload.to_string())
    }

    #[test]
    fn test_dispatch_window_capacity() {
        let mut window = DispatchWindow::new(2);
        assert!(window.has_capacity());
        assert_eq!(window.in_flight_count(), 0);

        window
            .mark_dispatched(1, create_test_delivery("m1"))
            .unwrap();
        assert!(window.has_capacity());
        assert_eq!(window.in_flight_count(), 1);

        window
            .mark_dispatched(2, create_test_delivery("m2"))
            .unwrap();
        assert!(!window.has_capacity());
        assert_eq!(window.in_flight_count(), 2);

        // Tentative de dépassement de capacité
        let err = window
            .mark_dispatched(3, create_test_delivery("m3"))
            .unwrap_err();
        assert_eq!(
            err,
            DispatchWindowError::CapacityExceeded { current: 2, max: 2 }
        );
    }

    #[test]
    fn test_dispatch_window_in_order_acks() {
        let mut window = DispatchWindow::new(5);
        window
            .mark_dispatched(1, create_test_delivery("m1"))
            .unwrap();
        window
            .mark_dispatched(2, create_test_delivery("m2"))
            .unwrap();
        window
            .mark_dispatched(3, create_test_delivery("m3"))
            .unwrap();

        assert_eq!(window.safe_cursor(), None);

        // ACK 1
        assert_eq!(window.on_ack(1), AckOutcome::Advanced { safe_cursor: 1 });
        assert_eq!(window.safe_cursor(), Some(1));

        // ACK 2
        assert_eq!(window.on_ack(2), AckOutcome::Advanced { safe_cursor: 2 });
        assert_eq!(window.safe_cursor(), Some(2));

        // ACK 3
        assert_eq!(window.on_ack(3), AckOutcome::Advanced { safe_cursor: 3 });
        assert_eq!(window.safe_cursor(), Some(3));

        assert!(window.is_empty());
    }

    #[test]
    fn test_dispatch_window_out_of_order_acks() {
        let mut window = DispatchWindow::new(10);
        for i in 1..=4 {
            window
                .mark_dispatched(i, create_test_delivery(&format!("m{i}")))
                .unwrap();
        }

        // ACK 1 -> safe_cursor = 1
        assert_eq!(window.on_ack(1), AckOutcome::Advanced { safe_cursor: 1 });
        assert_eq!(window.safe_cursor(), Some(1));

        // ACK 3 (désordonné : 2 est manquant) -> le curseur DOIT rester à 1
        assert_eq!(
            window.on_ack(3),
            AckOutcome::Accepted {
                current_safe_cursor: Some(1)
            }
        );
        assert_eq!(window.safe_cursor(), Some(1));

        // ACK 4 (désordonné : 2 est toujours manquant) -> le curseur DOIT rester à 1
        assert_eq!(
            window.on_ack(4),
            AckOutcome::Accepted {
                current_safe_cursor: Some(1)
            }
        );
        assert_eq!(window.safe_cursor(), Some(1));

        // Enfin ACK 2 : comble le trou -> saut immédiat de 1 à 4 !
        assert_eq!(window.on_ack(2), AckOutcome::Advanced { safe_cursor: 4 });
        assert_eq!(window.safe_cursor(), Some(4));
        assert!(window.is_empty());
    }

    #[test]
    fn test_dispatch_window_duplicate_ack() {
        let mut window = DispatchWindow::new(5);
        window
            .mark_dispatched(1, create_test_delivery("m1"))
            .unwrap();

        assert_eq!(window.on_ack(1), AckOutcome::Advanced { safe_cursor: 1 });

        // Second ACK sur 1 (duplicata réseau)
        assert_eq!(window.on_ack(1), AckOutcome::DuplicateAck(1));
        assert_eq!(window.safe_cursor(), Some(1));
    }

    #[test]
    fn test_dispatch_window_unknown_ack() {
        let mut window = DispatchWindow::new(5);
        window
            .mark_dispatched(10, create_test_delivery("m10"))
            .unwrap();

        // ACK sur un offset 999 jamais dispatché
        assert_eq!(window.on_ack(999), AckOutcome::UnknownOffset(999));
        assert_eq!(window.safe_cursor(), None);
    }

    #[test]
    fn test_dispatch_window_skipped_gap_resolution() {
        let mut window = DispatchWindow::new(10);
        window
            .mark_dispatched(1, create_test_delivery("m1"))
            .unwrap();
        window
            .mark_dispatched(2, create_test_delivery("m2"))
            .unwrap();
        window
            .mark_dispatched(3, create_test_delivery("m3"))
            .unwrap();

        // 1 est ACKé
        assert_eq!(window.on_ack(1), AckOutcome::Advanced { safe_cursor: 1 });

        // 3 est ACKé (2 est manquant)
        assert_eq!(
            window.on_ack(3),
            AckOutcome::Accepted {
                current_safe_cursor: Some(1)
            }
        );
        assert_eq!(window.safe_cursor(), Some(1));

        // 2 a épuisé ses retries et est skippé/résolu en DLQ
        let new_cursor = window.on_skipped(2);
        assert_eq!(new_cursor, Some(3));
        assert_eq!(window.safe_cursor(), Some(3));
        assert!(window.is_empty());
    }

    #[test]
    fn test_dispatch_window_unresolved_failure_blocks_cursor() {
        let mut window = DispatchWindow::new(10);
        let policy = DeliveryPolicy::default();

        window
            .mark_dispatched(1, create_test_delivery("m1"))
            .unwrap();
        window
            .mark_dispatched(2, create_test_delivery("m2"))
            .unwrap();
        window
            .mark_dispatched(3, create_test_delivery("m3"))
            .unwrap();

        window.on_ack(1);
        window.on_ack(3);
        assert_eq!(window.safe_cursor(), Some(1));

        // 2 est NACKé (en attente de retry)
        let nack_res = window.on_nack(2, &policy, Some("transient error".to_string()));
        assert!(nack_res);

        // Tant que 2 n'est pas résolu, le safe_cursor DOIT rester impérativement bloqué à 1
        assert_eq!(window.safe_cursor(), Some(1));
        assert_eq!(window.in_flight_count(), 1);
        assert!(window.get(2).unwrap().is_waiting_to_retry());
    }

    #[test]
    fn test_dispatch_window_overflow_limits() {
        let max_near = u64::MAX - 2;
        let mut window = DispatchWindow::with_initial_cursor(5, max_near);
        assert_eq!(window.safe_cursor(), Some(max_near));

        let off1 = u64::MAX - 1;
        let off2 = u64::MAX;

        window
            .mark_dispatched(off1, create_test_delivery("near_max1"))
            .unwrap();
        window
            .mark_dispatched(off2, create_test_delivery("near_max2"))
            .unwrap();

        // ACK off1
        assert_eq!(
            window.on_ack(off1),
            AckOutcome::Advanced { safe_cursor: off1 }
        );
        assert_eq!(window.safe_cursor(), Some(off1));

        // ACK off2 (atteint u64::MAX sans overflow)
        assert_eq!(
            window.on_ack(off2),
            AckOutcome::Advanced { safe_cursor: off2 }
        );
        assert_eq!(window.safe_cursor(), Some(off2));
    }

    #[test]
    fn test_dispatch_window_timeout_and_retry_collections() {
        let mut window = DispatchWindow::new(5);
        let policy = DeliveryPolicy {
            ack_timeout: Duration::from_millis(50),
            max_redelivery_count: 2,
            ..Default::default()
        };

        let mut d1 = create_test_delivery("m1");
        d1.on_send_attempt("w1", policy.ack_timeout);
        window.mark_dispatched(1, d1).unwrap();

        let mut d2 = create_test_delivery("m2");
        d2.on_send_attempt("w2", Duration::from_secs(60));
        window.mark_dispatched(2, d2).unwrap();

        let now = Instant::now() + Duration::from_millis(60);
        let timed_out = window.collect_ack_timed_out(now);
        assert_eq!(timed_out, vec![1]);

        // Appliquer timeout sur 1
        window.on_nack(1, &policy, Some("timeout".to_string()));
        assert!(window.get(1).unwrap().is_waiting_to_retry());

        // Réattribution immédiate suite à déconnexion de w2
        window.force_retry_for_consumer("w2", Some("w2 died".to_string()));
        assert!(window.get(2).unwrap().is_retry_ready(Instant::now()));

        // Test des collectes et accesseurs
        assert_eq!(window.max_capacity(), 5);
        assert_eq!(window.highest_dispatched_offset(), Some(2));
        assert!(window.get_mut(2).is_some());

        let ready = window.collect_retry_ready(Instant::now());
        assert_eq!(ready, vec![2]);

        // Provoquer un 2ème essai puis l'épuisement sur 1
        window
            .get_mut(1)
            .unwrap()
            .on_send_attempt("w1", policy.ack_timeout);
        window.on_nack(1, &policy, Some("exhausted".to_string()));
        let exhausted = window.collect_retry_exhausted();
        assert_eq!(exhausted, vec![1]);
    }
}
