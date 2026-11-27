// SPDX-License-Identifier: AGPL-3.0-only

//! Mesures propres au dépôt authentifié (plan du lot 6, §16.3) : authentifications par issue,
//! commandes refusées avant TLS ou avant `AUTH`, usurpations refusées, messages mis en file.
//! Aucune adresse, aucun compte, aucun domaine.

use std::collections::BTreeMap;
use std::sync::atomic::{AtomicU64, Ordering};

use super::AuthRefusal;

/// Compteurs du dépôt authentifié d'un nœud.
#[derive(Debug, Default)]
pub struct SubmissionMetrics {
    auth_succeeded: AtomicU64,
    auth_invalid: AtomicU64,
    auth_forbidden: AtomicU64,
    auth_locked: AtomicU64,
    auth_unavailable: AtomicU64,
    auth_malformed: AtomicU64,
    tls_required: AtomicU64,
    auth_required: AtomicU64,
    spoofing: AtomicU64,
    queued: AtomicU64,
    queued_recipients: AtomicU64,
}

fn bump(counter: &AtomicU64, amount: u64) {
    counter.fetch_add(amount, Ordering::Relaxed);
}

impl SubmissionMetrics {
    pub(crate) fn auth_succeeded(&self) {
        bump(&self.auth_succeeded, 1);
    }

    pub(crate) fn auth_refused(&self, refusal: AuthRefusal) {
        bump(
            match refusal {
                AuthRefusal::Invalid => &self.auth_invalid,
                AuthRefusal::Forbidden => &self.auth_forbidden,
                AuthRefusal::Locked => &self.auth_locked,
                AuthRefusal::Unavailable => &self.auth_unavailable,
            },
            1,
        );
    }

    /// Échange `AUTH` illisible ou annulé (Base64, champs, `authzid` refusé).
    pub(crate) fn auth_malformed(&self) {
        bump(&self.auth_malformed, 1);
    }

    /// `AUTH` ou `MAIL` avant TLS.
    pub(crate) fn tls_required(&self) {
        bump(&self.tls_required, 1);
    }

    /// `MAIL` avant `AUTH`.
    pub(crate) fn auth_required(&self) {
        bump(&self.auth_required, 1);
    }

    /// Adresse d'expéditeur refusée (`MAIL FROM` ou champs d'en-tête).
    pub(crate) fn spoofing(&self) {
        bump(&self.spoofing, 1);
    }

    /// Message inscrit dans la file d'envoi avec `recipients` destinataires.
    pub(crate) fn queued(&self, recipients: u64) {
        bump(&self.queued, 1);
        bump(&self.queued_recipients, recipients);
    }

    /// Valeurs des compteurs, par nom (`auth_refused.invalid`, `submission_spoofing`...).
    pub fn snapshot(&self) -> BTreeMap<String, u64> {
        let load = |counter: &AtomicU64| counter.load(Ordering::Relaxed);
        BTreeMap::from([
            ("auth_succeeded".to_string(), load(&self.auth_succeeded)),
            ("auth_refused.invalid".to_string(), load(&self.auth_invalid)),
            (
                "auth_refused.forbidden".to_string(),
                load(&self.auth_forbidden),
            ),
            ("auth_refused.locked".to_string(), load(&self.auth_locked)),
            (
                "auth_refused.unavailable".to_string(),
                load(&self.auth_unavailable),
            ),
            (
                "auth_refused.malformed".to_string(),
                load(&self.auth_malformed),
            ),
            ("tls_required".to_string(), load(&self.tls_required)),
            ("auth_required".to_string(), load(&self.auth_required)),
            ("submission_spoofing".to_string(), load(&self.spoofing)),
            ("submissions_queued".to_string(), load(&self.queued)),
            (
                "submission_recipients_queued".to_string(),
                load(&self.queued_recipients),
            ),
        ])
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counters_are_named_without_personal_data() {
        let metrics = SubmissionMetrics::default();
        metrics.auth_succeeded();
        metrics.auth_refused(AuthRefusal::Invalid);
        metrics.auth_refused(AuthRefusal::Forbidden);
        metrics.spoofing();
        metrics.queued(3);
        let values = metrics.snapshot();
        assert_eq!(values["auth_succeeded"], 1);
        assert_eq!(values["auth_refused.invalid"], 1);
        assert_eq!(values["auth_refused.forbidden"], 1);
        assert_eq!(values["submission_spoofing"], 1);
        assert_eq!(values["submission_recipients_queued"], 3);
        assert!(values.keys().all(|key| !key.contains('@')));
    }
}
