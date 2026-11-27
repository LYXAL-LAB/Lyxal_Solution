// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures de l'envoi d'un nœud (plan du lot 6, §16.3) : destinataires remis, relayés, retentés,
//! en échec et expirés par étape, avis produits et supprimés, transferts d'alias et avis reçus
//! de la route locale, connexions ouvertes et
//! réutilisées, TLS utilisé, non offert, en repli, durée des transactions, destinations
//! suspendues, messages non signés, réservations. **Aucune adresse ni aucun domaine** (décision
//! E28) : seuls des compteurs nommés.

use std::collections::BTreeMap;
use std::sync::atomic::{AtomicU64, Ordering};

use crate::delivery::ForwardResult;
use crate::models::AttemptStage;

/// Étapes comptées, dans l'ordre des mesures.
const STAGES: [AttemptStage; 9] = [
    AttemptStage::Dns,
    AttemptStage::Connect,
    AttemptStage::Tls,
    AttemptStage::Greeting,
    AttemptStage::Mail,
    AttemptStage::Rcpt,
    AttemptStage::Data,
    AttemptStage::Local,
    AttemptStage::Content,
];

/// Nom d'une étape.
pub fn stage_name(stage: AttemptStage) -> &'static str {
    match stage {
        AttemptStage::Dns => "dns",
        AttemptStage::Connect => "connect",
        AttemptStage::Tls => "tls",
        AttemptStage::Greeting => "greeting",
        AttemptStage::Mail => "mail",
        AttemptStage::Rcpt => "rcpt",
        AttemptStage::Data => "data",
        AttemptStage::Local => "local",
        AttemptStage::Content => "content",
        AttemptStage::Expired => "expired",
        AttemptStage::Canceled => "canceled",
        AttemptStage::Bounce => "bounce",
    }
}

fn stage_index(stage: AttemptStage) -> usize {
    STAGES.iter().position(|known| *known == stage).unwrap_or(0)
}

/// Compteurs de l'envoi du nœud.
#[derive(Debug, Default)]
pub struct OutboundMetrics {
    claims: AtomicU64,
    claimed: AtomicU64,
    claims_lost: AtomicU64,
    delivered: AtomicU64,
    relayed: AtomicU64,
    delivered_local: AtomicU64,
    retried: [AtomicU64; 9],
    failed: [AtomicU64; 9],
    expired: AtomicU64,
    released: AtomicU64,
    connections_opened: AtomicU64,
    connections_reused: AtomicU64,
    tls_used: AtomicU64,
    tls_not_offered: AtomicU64,
    tls_fallbacks: AtomicU64,
    transactions: AtomicU64,
    transaction_millis_total: AtomicU64,
    transaction_millis_max: AtomicU64,
    destinations_unreachable: AtomicU64,
    dkim_signed: AtomicU64,
    dkim_unsigned: AtomicU64,
    prepared: AtomicU64,
    malformed: AtomicU64,
    content_unreadable: AtomicU64,
    dsn_produced: AtomicU64,
    dsn_suppressed: AtomicU64,
    forwards_queued: AtomicU64,
    forwards_limited: AtomicU64,
    forwards_refused: AtomicU64,
    returns_received: AtomicU64,
    result_write_failures: AtomicU64,
}

fn add(counter: &AtomicU64, value: u64) {
    counter.fetch_add(value, Ordering::Relaxed);
}

impl OutboundMetrics {
    /// Réservation faite (`count` destinataires).
    pub fn claim(&self, count: usize) {
        add(&self.claims, 1);
        add(&self.claimed, count as u64);
    }

    /// Destinataires perdus (réservation reprise par un autre nœud ou bail échu).
    pub fn lost(&self, count: usize) {
        add(&self.claims_lost, count as u64);
    }

    /// Destinataire remis par le serveur final.
    pub fn delivered(&self, local: bool) {
        add(
            if local {
                &self.delivered_local
            } else {
                &self.delivered
            },
            1,
        );
    }

    /// Destinataire relayé (serveur sans `DSN`).
    pub fn relayed(&self) {
        add(&self.relayed, 1);
    }

    /// Échec temporaire à l'étape `stage`.
    pub fn retried(&self, stage: AttemptStage) {
        add(&self.retried[stage_index(stage)], 1);
    }

    /// Échec définitif à l'étape `stage`.
    pub fn failed(&self, stage: AttemptStage) {
        add(&self.failed[stage_index(stage)], 1);
    }

    /// Destinataire expiré.
    pub fn expired(&self) {
        add(&self.expired, 1);
    }

    /// Destinataires rendus sans essai compté (arrêt, cadence).
    pub fn released(&self, count: usize) {
        add(&self.released, count as u64);
    }

    /// Connexion ouverte (`reused` : prise au pool).
    pub fn connection(&self, reused: bool) {
        add(
            if reused {
                &self.connections_reused
            } else {
                &self.connections_opened
            },
            1,
        );
    }

    /// TLS d'une nouvelle connexion : utilisé, non offert, ou repli en clair.
    pub fn tls(&self, used: bool, fallback: bool) {
        add(
            if fallback {
                &self.tls_fallbacks
            } else if used {
                &self.tls_used
            } else {
                &self.tls_not_offered
            },
            1,
        );
    }

    /// Durée d'une transaction.
    pub fn transaction(&self, millis: u64) {
        add(&self.transactions, 1);
        add(&self.transaction_millis_total, millis);
        self.transaction_millis_max
            .fetch_max(millis, Ordering::Relaxed);
    }

    /// Destination injoignable (suspendue).
    pub fn unreachable(&self) {
        add(&self.destinations_unreachable, 1);
    }

    /// Envoi préparé : signé (`signatures` > 0) ou non, illisible.
    pub fn prepared(&self, signatures: usize, malformed: bool) {
        add(&self.prepared, 1);
        if malformed {
            add(&self.malformed, 1);
        } else if signatures > 0 {
            add(&self.dkim_signed, 1);
        } else {
            add(&self.dkim_unsigned, 1);
        }
    }

    /// Contenu d'un envoi illisible (fichier altéré, stockage indisponible).
    pub fn content_unreadable(&self) {
        add(&self.content_unreadable, 1);
    }

    /// Avis produit, ou supprimé (expéditeur sans boîte).
    pub fn dsn(&self, produced: bool) {
        add(
            if produced {
                &self.dsn_produced
            } else {
                &self.dsn_suppressed
            },
            1,
        );
    }

    /// Transfert d'un alias vers l'extérieur fait par la route locale.
    pub fn forwarded(&self, result: ForwardResult) {
        add(
            match result {
                ForwardResult::Queued => &self.forwards_queued,
                ForwardResult::Limited => &self.forwards_limited,
                ForwardResult::Refused => &self.forwards_refused,
            },
            1,
        );
    }

    /// Message reçu par la route locale sur une adresse de retour (avis d'un transfert).
    pub fn returned(&self) {
        add(&self.returns_received, 1);
    }

    /// Transferts de la route locale non faits faute de place dans la limite de l'organisation
    /// (sonde).
    pub fn forwards_limited(&self) -> u64 {
        self.forwards_limited.load(Ordering::Relaxed)
    }

    /// Résultat non écrit (base indisponible) : le bail expirera et le destinataire sera repris.
    pub fn result_write_failure(&self) {
        add(&self.result_write_failures, 1);
    }

    /// Envois non signés depuis le démarrage (sonde).
    pub fn unsigned(&self) -> u64 {
        self.dkim_unsigned.load(Ordering::Relaxed)
    }

    /// Contenus illisibles depuis le démarrage (sonde).
    pub fn unreadable(&self) -> u64 {
        self.content_unreadable.load(Ordering::Relaxed)
    }

    /// Compteurs nommés, pour `/metrics`.
    pub fn snapshot(&self) -> BTreeMap<String, u64> {
        let load = |counter: &AtomicU64| counter.load(Ordering::Relaxed);
        let mut values = BTreeMap::new();
        for (name, counter) in [
            ("claims", &self.claims),
            ("recipients_claimed", &self.claimed),
            ("recipients_lost", &self.claims_lost),
            ("recipients_delivered", &self.delivered),
            ("recipients_delivered_local", &self.delivered_local),
            ("recipients_relayed", &self.relayed),
            ("recipients_expired", &self.expired),
            ("recipients_released", &self.released),
            ("connections_opened", &self.connections_opened),
            ("connections_reused", &self.connections_reused),
            ("tls_used", &self.tls_used),
            ("tls_not_offered", &self.tls_not_offered),
            ("tls_fallbacks", &self.tls_fallbacks),
            ("transactions", &self.transactions),
            ("transaction_millis_total", &self.transaction_millis_total),
            ("transaction_millis_max", &self.transaction_millis_max),
            ("destinations_unreachable", &self.destinations_unreachable),
            ("submissions_prepared", &self.prepared),
            ("submissions_malformed", &self.malformed),
            ("dkim_signed", &self.dkim_signed),
            ("dkim_unsigned", &self.dkim_unsigned),
            ("contents_unreadable", &self.content_unreadable),
            ("dsn_produced", &self.dsn_produced),
            ("dsn_suppressed", &self.dsn_suppressed),
            ("forwards_queued", &self.forwards_queued),
            ("forwards_limited", &self.forwards_limited),
            ("forwards_refused", &self.forwards_refused),
            ("returns_received", &self.returns_received),
            ("result_write_failures", &self.result_write_failures),
        ] {
            values.insert(name.to_string(), load(counter));
        }
        for (index, stage) in STAGES.iter().enumerate() {
            let name = stage_name(*stage);
            values.insert(
                format!("recipients_retried.{name}"),
                load(&self.retried[index]),
            );
            values.insert(
                format!("recipients_failed.{name}"),
                load(&self.failed[index]),
            );
        }
        values
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counters_are_named_without_personal_data() {
        let metrics = OutboundMetrics::default();
        metrics.claim(3);
        metrics.delivered(false);
        metrics.delivered(true);
        metrics.retried(AttemptStage::Connect);
        metrics.failed(AttemptStage::Rcpt);
        metrics.tls(true, false);
        metrics.tls(false, true);
        metrics.transaction(12);
        metrics.transaction(30);
        metrics.prepared(0, false);
        let values = metrics.snapshot();
        assert_eq!(values["recipients_claimed"], 3);
        assert_eq!(values["recipients_delivered"], 1);
        assert_eq!(values["recipients_delivered_local"], 1);
        assert_eq!(values["recipients_retried.connect"], 1);
        assert_eq!(values["recipients_failed.rcpt"], 1);
        assert_eq!(values["tls_fallbacks"], 1);
        assert_eq!(values["transaction_millis_max"], 30);
        assert_eq!(metrics.unsigned(), 1);
        assert!(values.keys().all(|key| !key.contains('@')));
    }
}
