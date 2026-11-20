// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures des écoutes : connexions acceptées, actives, refusées par raison, en-têtes PROXY
//! refusés, poignées de main TLS en échec, sessions en échec. Aucune adresse IP (décision G13).

use lyxal_mail::net::RefusalReason;
use serde::Serialize;
use std::collections::BTreeMap;
use std::sync::atomic::{AtomicU64, Ordering};

/// Raison d'une connexion fermée sans être servie.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Refusal {
    /// Plafond de l'écoute atteint : fermeture immédiate, sans ligne de refus.
    ListenerFull,
    /// Refus poli (ligne du protocole ; fermeture sans poignée de main sur une écoute à TLS
    /// implicite).
    Polite(RefusalReason),
    /// En-tête PROXY absent, illisible ou hors délai, depuis un réseau de répartiteur.
    ProxyHeader,
}

impl Refusal {
    /// Nom de la raison pour le journal et les mesures.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::ListenerFull => "listener_full",
            Self::Polite(reason) => reason.as_str(),
            Self::ProxyHeader => "proxy_header",
        }
    }
}

/// Raisons comptées par l'acceptation.
const REASONS: [Refusal; 6] = [
    Refusal::ListenerFull,
    Refusal::ProxyHeader,
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
    tls_handshake_failures: AtomicU64,
    via_proxy: AtomicU64,
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

    pub fn tls_handshake_failed(&self) {
        self.tls_handshake_failures.fetch_add(1, Ordering::Relaxed);
    }

    pub fn proxied(&self) {
        self.via_proxy.fetch_add(1, Ordering::Relaxed);
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
            tls_handshake_failures: self.tls_handshake_failures.load(Ordering::Relaxed),
            via_proxy: self.via_proxy.load(Ordering::Relaxed),
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
    /// Poignées de main TLS en échec ou hors délai (implicites et STARTTLS).
    pub tls_handshake_failures: u64,
    /// Connexions dont l'adresse du client vient d'un en-tête PROXY.
    pub via_proxy: u64,
}
