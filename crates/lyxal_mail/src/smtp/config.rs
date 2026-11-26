// SPDX-License-Identifier: AGPL-3.0-only

//! Réglages de la session SMTP entrante (section `[smtp]` de l'hôte, plan du lot 5, §7.6 et
//! §11.2, décision S19). Les valeurs par défaut et les bornes sont celles du plan ; l'hôte lit
//! sa configuration puis appelle [`SmtpConfig::validate`].

use std::time::Duration;

use crate::auth::is_valid_domain;
use lyxal_mail_proto::smtp::{
    SmtpLimits, MAX_LINE_BYTES, MAX_MESSAGE_BYTES, MIN_LINE_BYTES, MIN_MESSAGE_BYTES,
};

/// Taille maximale d'un message par défaut (50 Mio, décision M18), annoncée par `SIZE`.
pub const DEFAULT_MAX_MESSAGE_BYTES: u64 = 52_428_800;
/// Destinataires au plus par transaction (RFC 5321 §4.5.3.1.8).
pub const DEFAULT_MAX_RECIPIENTS: usize = 100;
/// Messages au plus par session.
pub const DEFAULT_MAX_MESSAGES_PER_SESSION: u32 = 50;
/// Erreurs tolérées dans une session avant `421 4.7.0` et fermeture.
pub const DEFAULT_MAX_ERRORS: u32 = 10;
/// Longueur maximale d'une ligne de commande, CRLF compris.
pub const DEFAULT_MAX_LINE_BYTES: usize = 4_096;
/// Attente d'une commande (RFC 5321 §4.5.3.2 : le client attend 5 minutes).
pub const DEFAULT_COMMAND_TIMEOUT: Duration = Duration::from_secs(300);
/// Attente entre deux blocs de données (RFC 5321 §4.5.3.2.5).
pub const DEFAULT_DATA_TIMEOUT: Duration = Duration::from_secs(180);
/// Durée maximale d'une session.
pub const DEFAULT_SESSION_MAX: Duration = Duration::from_secs(1_800);
/// Débit minimal des données après 30 s de lecture (lenteur volontaire).
pub const DEFAULT_DATA_MIN_BYTES_PER_SECOND: u64 = 1_024;
/// Messages par minute et par réseau (`/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`).
pub const DEFAULT_MESSAGES_PER_NETWORK_PER_MINUTE: [u64; 3] = [60, 180, 540];

/// Réglage hors bornes : le message nomme le réglage à corriger.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
#[error("{0}")]
pub struct SmtpConfigError(pub String);

/// Réglages de la réception SMTP.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SmtpConfig {
    /// Nom de l'hôte : bannière, `Received`, `authserv-id` d'`Authentication-Results` (nom de
    /// domaine en forme ASCII, obligatoire).
    pub hostname: String,
    /// Taille maximale d'un message, annoncée par `SIZE` (1 Mio à 1 Gio).
    pub max_message_bytes: u64,
    /// Destinataires au plus par transaction (1 à 1 000).
    pub max_recipients: usize,
    /// Messages au plus par session (1 à 1 000).
    pub max_messages_per_session: u32,
    /// Erreurs tolérées avant fermeture (1 à 100).
    pub max_errors: u32,
    /// Longueur maximale d'une ligne de commande (512 à 65 536).
    pub max_line_bytes: usize,
    /// Attente d'une commande (30 s à 1 h).
    pub command_timeout: Duration,
    /// Attente entre deux blocs de données (30 s à 1 h).
    pub data_timeout: Duration,
    /// Durée maximale d'une session (60 s à 24 h).
    pub session_max: Duration,
    /// Débit minimal des données après 30 s (0 à 1 Mio par seconde ; 0 : aucun).
    pub data_min_bytes_per_second: u64,
    /// Messages par minute et par réseau, trois niveaux (1 à 1 000 000).
    pub messages_per_network_per_minute: [u64; 3],
    /// Vrai : la politique DMARC de l'expéditeur est appliquée (`reject`, `quarantine`) ;
    /// faux : résultat seulement (mise en service progressive).
    pub dmarc_enforce: bool,
}

impl SmtpConfig {
    /// Réglages par défaut pour le nom d'hôte `hostname`.
    pub fn new(hostname: impl Into<String>) -> Self {
        Self {
            hostname: hostname.into(),
            max_message_bytes: DEFAULT_MAX_MESSAGE_BYTES,
            max_recipients: DEFAULT_MAX_RECIPIENTS,
            max_messages_per_session: DEFAULT_MAX_MESSAGES_PER_SESSION,
            max_errors: DEFAULT_MAX_ERRORS,
            max_line_bytes: DEFAULT_MAX_LINE_BYTES,
            command_timeout: DEFAULT_COMMAND_TIMEOUT,
            data_timeout: DEFAULT_DATA_TIMEOUT,
            session_max: DEFAULT_SESSION_MAX,
            data_min_bytes_per_second: DEFAULT_DATA_MIN_BYTES_PER_SECOND,
            messages_per_network_per_minute: DEFAULT_MESSAGES_PER_NETWORK_PER_MINUTE,
            dmarc_enforce: true,
        }
    }

    /// Contrôle des bornes du plan (§7.6, §11.2).
    pub fn validate(&self) -> Result<(), SmtpConfigError> {
        let invalid = |message: &str| Err(SmtpConfigError(message.to_string()));
        if !self.hostname.is_ascii() || !is_valid_domain(&self.hostname, false) {
            return invalid("smtp.hostname : nom de domaine en forme ASCII (ex. mx.exemple.fr)");
        }
        if !(MIN_MESSAGE_BYTES..=MAX_MESSAGE_BYTES).contains(&self.max_message_bytes) {
            return invalid("smtp.max_message_bytes doit être compris entre 1 Mio et 1 Gio");
        }
        if !(1..=1_000).contains(&self.max_recipients) {
            return invalid("smtp.max_recipients doit être compris entre 1 et 1000");
        }
        if !(1..=1_000).contains(&self.max_messages_per_session) {
            return invalid("smtp.max_messages_per_session doit être compris entre 1 et 1000");
        }
        if !(1..=100).contains(&self.max_errors) {
            return invalid("smtp.max_errors doit être compris entre 1 et 100");
        }
        if !(MIN_LINE_BYTES..=MAX_LINE_BYTES).contains(&self.max_line_bytes) {
            return invalid("smtp.max_line_bytes doit être compris entre 512 et 65536");
        }
        let delay = Duration::from_secs(30)..=Duration::from_secs(3_600);
        if !delay.contains(&self.command_timeout) {
            return invalid("smtp.command_timeout_seconds doit être compris entre 30 et 3600");
        }
        if !delay.contains(&self.data_timeout) {
            return invalid("smtp.data_timeout_seconds doit être compris entre 30 et 3600");
        }
        if !(Duration::from_secs(60)..=Duration::from_secs(86_400)).contains(&self.session_max) {
            return invalid("smtp.session_max_seconds doit être compris entre 60 et 86400");
        }
        if self.data_min_bytes_per_second > 1 << 20 {
            return invalid("smtp.data_min_bytes_per_second doit être compris entre 0 et 1048576");
        }
        if !self
            .messages_per_network_per_minute
            .iter()
            .all(|value| (1..=1_000_000).contains(value))
        {
            return invalid("smtp.messages_per_network_per_minute : valeurs entre 1 et 1000000");
        }
        Ok(())
    }

    /// Limites de la syntaxe (`lyxal_mail_proto`).
    pub(crate) fn syntax_limits(&self) -> SmtpLimits {
        SmtpLimits::new(self.max_line_bytes, self.max_message_bytes).unwrap_or_default()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn defaults_are_valid_and_bounds_are_checked() {
        let config = SmtpConfig::new("mx.alpha.test");
        assert_eq!(config.validate(), Ok(()));
        assert_eq!(config.syntax_limits().max_message_bytes(), 52_428_800);
        let refused = |change: fn(&mut SmtpConfig)| {
            let mut config = SmtpConfig::new("mx.alpha.test");
            change(&mut config);
            config.validate().is_err()
        };
        assert!(refused(|c| c.hostname = String::new()));
        assert!(refused(|c| c.hostname = "mx.exemple.fr\r\nX: y".into()));
        assert!(refused(|c| c.hostname = "mx.éxemple.fr".into()));
        assert!(refused(|c| c.max_message_bytes = 1_000));
        assert!(refused(|c| c.max_recipients = 0));
        assert!(refused(|c| c.max_recipients = 1_001));
        assert!(refused(|c| c.max_messages_per_session = 0));
        assert!(refused(|c| c.max_errors = 101));
        assert!(refused(|c| c.max_line_bytes = 100));
        assert!(refused(|c| c.command_timeout = Duration::from_secs(10)));
        assert!(refused(|c| c.data_timeout = Duration::from_secs(4_000)));
        assert!(refused(|c| c.session_max = Duration::from_secs(10)));
        assert!(refused(|c| c.data_min_bytes_per_second = 2 << 20));
        assert!(refused(|c| c.messages_per_network_per_minute = [0, 1, 1]));
    }
}
