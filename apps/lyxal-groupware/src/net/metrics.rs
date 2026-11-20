// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures des écoutes : connexions acceptées, actives, refusées par raison, sessions en échec.
//! Aucune adresse IP (décision G13).

use lyxal_mail::net::RefusalReason;
use serde::Serialize;
use std::collections::BTreeMap;
use std::sync::atomic::{AtomicU64, Ordering};

/// Raison d'une connexion fermée sans être servie.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Refusal {
    /// Plafond de l'écoute atteint : fermeture immédiate, sans ligne de refus.
    ListenerFull,
    /// Refus poli (ligne du protocole).
    Polite(RefusalReason),
}

impl Refusal {
    /// Nom de la raison pour le journal et les mesures.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::ListenerFull => "listener_full",
            Self::Polite(reason) => reason.as_str(),
        }
    }
}

/// Raisons comptées par l'acceptation.
const REASONS: [Refusal; 5] = [
    Refusal::ListenerFull,
    Refusal::Polite(RefusalReason::Blocked),
    Refusal::Polite(RefusalReason::RateLimited),
    Refusal::Polite(RefusalReason::TooManyConnections),
    Refusal::Polite(RefusalReason::MemoryBudget),
];

/// Compteurs d'une écoute.
#[derive(Debug, Default)]
pub struct ListenerMetrics {
    accepted: AtomicU64,
    refused: [AtomicU64; REASONS.len()],
    failed_sessions: AtomicU64,
    accept_errors: AtomicU64,
}

impl ListenerMetrics {
    pub fn accepted(&self) {
        self.accepted.fetch_add(1, Ordering::Relaxed);
    }

    pub fn refused(&self, refusal: Refusal) {
        if let Some(index) = REASONS.iter().position(|r| *r == refusal) {
            self.refused[index].fetch_add(1, Ordering::Relaxed);
        }
    }

    pub fn session_failed(&self) {
        self.failed_sessions.fetch_add(1, Ordering::Relaxed);
    }

    pub fn accept_error(&self) {
        self.accept_errors.fetch_add(1, Ordering::Relaxed);
    }

    /// Compteurs, avec les connexions actives `active` sur un plafond `max_connections`.
    pub fn snapshot(
        &self,
        protocol: &'static str,
        active: u32,
        max_connections: u32,
    ) -> ListenerSnapshot {
        ListenerSnapshot {
            protocol,
            accepted: self.accepted.load(Ordering::Relaxed),
            active,
            max_connections,
            refused: REASONS
                .iter()
                .zip(&self.refused)
                .map(|(reason, count)| (reason.as_str(), count.load(Ordering::Relaxed)))
                .collect(),
            failed_sessions: self.failed_sessions.load(Ordering::Relaxed),
            accept_errors: self.accept_errors.load(Ordering::Relaxed),
        }
    }
}

/// Mesures d'une écoute, pour `/metrics`.
#[derive(Debug, Serialize)]
pub struct ListenerSnapshot {
    pub protocol: &'static str,
    /// Connexions servies (remises à la session du protocole).
    pub accepted: u64,
    /// Connexions ouvertes.
    pub active: u32,
    pub max_connections: u32,
    /// Connexions refusées, par raison.
    pub refused: BTreeMap<&'static str, u64>,
    /// Sessions terminées sur erreur du transport.
    pub failed_sessions: u64,
    /// Erreurs d'acceptation (hors erreurs passagères).
    pub accept_errors: u64,
}
