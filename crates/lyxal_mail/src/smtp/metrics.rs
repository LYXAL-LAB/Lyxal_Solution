// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures de la réception SMTP d'un nœud (plan du lot 5, §11.3) : sessions, messages acceptés
//! et refusés par motif, destinataires, résultats d'authenticité, remises dupliquées évitées,
//! durée des remises, DNS. Aucune adresse, aucun domaine.

use std::collections::BTreeMap;
use std::sync::atomic::{AtomicU64, Ordering};

/// Motif d'un message ou d'un destinataire refusé, pour les mesures et le journal.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum RefusedReason {
    /// Domaine qui n'est pas à nous (aucun relais).
    Relay,
    /// Destinataire inconnu.
    Unknown,
    /// Compte désactivé ou en suppression.
    Disabled,
    /// Quota plein.
    Quota,
    /// Taille.
    Size,
    /// Politique DMARC de l'expéditeur (`reject`).
    Dmarc,
    /// Antivirus : message infecté.
    Antivirus,
    /// Contrebande SMTP (fins de ligne isolées).
    Smuggling,
    /// Limites de la session (destinataires, messages, erreurs, cadence, mémoire, délais).
    Limits,
    /// Message illisible (MIME, octet nul).
    Malformed,
    /// `From` absent ou multiple, boucle.
    Policy,
    /// Refus temporaire (base, stockage, antivirus ou DNS indisponibles).
    Temporary,
}

impl RefusedReason {
    /// Tous les motifs, dans l'ordre des mesures.
    pub const ALL: [Self; 12] = [
        Self::Relay,
        Self::Unknown,
        Self::Disabled,
        Self::Quota,
        Self::Size,
        Self::Dmarc,
        Self::Antivirus,
        Self::Smuggling,
        Self::Limits,
        Self::Malformed,
        Self::Policy,
        Self::Temporary,
    ];

    /// Nom du motif.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Relay => "relay",
            Self::Unknown => "unknown",
            Self::Disabled => "disabled",
            Self::Quota => "quota",
            Self::Size => "size",
            Self::Dmarc => "dmarc",
            Self::Antivirus => "antivirus",
            Self::Smuggling => "smuggling",
            Self::Limits => "limits",
            Self::Malformed => "malformed",
            Self::Policy => "policy",
            Self::Temporary => "temporary",
        }
    }

    fn index(self) -> usize {
        Self::ALL.iter().position(|r| *r == self).unwrap_or(0)
    }
}

const SPF: [&str; 7] = [
    "none",
    "neutral",
    "pass",
    "fail",
    "softfail",
    "temperror",
    "permerror",
];
const DKIM: [&str; 7] = [
    "none",
    "pass",
    "fail",
    "neutral",
    "policy",
    "temperror",
    "permerror",
];
const DMARC: [&str; 5] = ["none", "pass", "fail", "temperror", "permerror"];

/// Compteurs de la réception SMTP d'un nœud.
#[derive(Debug, Default)]
pub struct SmtpMetrics {
    sessions: AtomicU64,
    messages_accepted: AtomicU64,
    messages_refused: [AtomicU64; 12],
    recipients_accepted: AtomicU64,
    recipients_refused: [AtomicU64; 12],
    spf: [AtomicU64; 7],
    dkim: [AtomicU64; 7],
    dmarc: [AtomicU64; 5],
    duplicates: AtomicU64,
    deliveries: AtomicU64,
    delivery_millis: AtomicU64,
    delivery_millis_max: AtomicU64,
    dns_queries: AtomicU64,
    dns_failures: AtomicU64,
}

fn bump(counter: &AtomicU64) {
    counter.fetch_add(1, Ordering::Relaxed);
}

fn bump_word(counters: &[AtomicU64], words: &[&str], word: &str) {
    if let Some(index) = words.iter().position(|w| *w == word) {
        if let Some(counter) = counters.get(index) {
            bump(counter);
        }
    }
}

impl SmtpMetrics {
    pub(crate) fn session(&self) {
        bump(&self.sessions);
    }

    pub(crate) fn accepted(&self) {
        bump(&self.messages_accepted);
    }

    pub(crate) fn refused(&self, reason: RefusedReason) {
        bump(&self.messages_refused[reason.index()]);
    }

    pub(crate) fn recipient_accepted(&self) {
        bump(&self.recipients_accepted);
    }

    pub(crate) fn recipient_refused(&self, reason: RefusedReason) {
        bump(&self.recipients_refused[reason.index()]);
    }

    pub(crate) fn authentication(&self, spf: &str, dkim: &[&str], dmarc: &[&str]) {
        bump_word(&self.spf, &SPF, spf);
        for word in dkim {
            bump_word(&self.dkim, &DKIM, word);
        }
        for word in dmarc {
            bump_word(&self.dmarc, &DMARC, word);
        }
    }

    pub(crate) fn duplicate(&self) {
        bump(&self.duplicates);
    }

    pub(crate) fn delivery_time(&self, millis: u64) {
        bump(&self.deliveries);
        self.delivery_millis.fetch_add(millis, Ordering::Relaxed);
        self.delivery_millis_max
            .fetch_max(millis, Ordering::Relaxed);
    }

    pub(crate) fn dns(&self, failed: bool) {
        bump(&self.dns_queries);
        if failed {
            bump(&self.dns_failures);
        }
    }

    /// Valeurs des compteurs, par nom (`messages_refused.relay`, `spf.pass`...).
    pub fn snapshot(&self) -> BTreeMap<String, u64> {
        let load = |counter: &AtomicU64| counter.load(Ordering::Relaxed);
        let mut values = BTreeMap::new();
        values.insert("sessions".to_string(), load(&self.sessions));
        values.insert(
            "messages_accepted".to_string(),
            load(&self.messages_accepted),
        );
        values.insert(
            "recipients_accepted".to_string(),
            load(&self.recipients_accepted),
        );
        for reason in RefusedReason::ALL {
            values.insert(
                format!("messages_refused.{}", reason.as_str()),
                load(&self.messages_refused[reason.index()]),
            );
            values.insert(
                format!("recipients_refused.{}", reason.as_str()),
                load(&self.recipients_refused[reason.index()]),
            );
        }
        for (prefix, words, counters) in [
            ("spf", &SPF[..], &self.spf[..]),
            ("dkim", &DKIM[..], &self.dkim[..]),
            ("dmarc", &DMARC[..], &self.dmarc[..]),
        ] {
            for (word, counter) in words.iter().zip(counters) {
                values.insert(format!("{prefix}.{word}"), load(counter));
            }
        }
        values.insert("duplicates_avoided".to_string(), load(&self.duplicates));
        values.insert("deliveries".to_string(), load(&self.deliveries));
        values.insert(
            "delivery_millis_total".to_string(),
            load(&self.delivery_millis),
        );
        values.insert(
            "delivery_millis_max".to_string(),
            load(&self.delivery_millis_max),
        );
        values.insert("dns_queries".to_string(), load(&self.dns_queries));
        values.insert("dns_failures".to_string(), load(&self.dns_failures));
        values
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counters_are_named_without_personal_data() {
        let metrics = SmtpMetrics::default();
        metrics.session();
        metrics.refused(RefusedReason::Dmarc);
        metrics.recipient_refused(RefusedReason::Relay);
        metrics.authentication("pass", &["pass", "fail"], &["pass"]);
        metrics.delivery_time(12);
        metrics.delivery_time(30);
        metrics.dns(true);
        let values = metrics.snapshot();
        assert_eq!(values["sessions"], 1);
        assert_eq!(values["messages_refused.dmarc"], 1);
        assert_eq!(values["recipients_refused.relay"], 1);
        assert_eq!(values["spf.pass"], 1);
        assert_eq!(values["dkim.fail"], 1);
        assert_eq!(values["delivery_millis_total"], 42);
        assert_eq!(values["delivery_millis_max"], 30);
        assert_eq!(values["dns_failures"], 1);
        assert!(values.keys().all(|key| !key.contains('@')));
    }
}
