// SPDX-License-Identifier: AGPL-3.0-only

//! Réglages de l'envoi d'un nœud (plan du lot 6, §5.4, §6, §16.2 ; décisions E7 à E11, E13) :
//! limites par nœud et par destination, délais, familles d'adresses, TLS, relais sortant.
//! Valeurs par défaut et bornes du plan ; [`OutboundConfig::validate`] refuse toute valeur hors
//! de ses bornes (l'hôte traduit l'erreur en `GROUPWARE_CONFIGURATION_INVALID`).

use std::fmt;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};
use std::time::Duration;

/// Famille d'adresses essayée, dans l'ordre donné.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum IpFamily {
    /// IPv4 (enregistrements A).
    Ipv4,
    /// IPv6 (enregistrements AAAA).
    Ipv6,
}

/// TLS vers les MX (décision E9).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum OutboundTls {
    /// STARTTLS quand il est annoncé, certificat non vérifié (RFC 7435), repli en clair une fois.
    Opportunistic,
    /// Jamais de TLS (essais seulement).
    Disabled,
}

/// TLS du relais sortant, toujours vérifié (décision E13).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RelayTls {
    /// STARTTLS exigé (port 587).
    StartTls,
    /// TLS dès la connexion (port 465, RFC 8314).
    Implicit,
}

/// Relais sortant (« smarthost ») : tout envoi extérieur passe par lui, sans résolution MX.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RelayConfig {
    /// Nom du relais (SNI et vérification du certificat).
    pub host: String,
    /// Port (587 ou 465 d'ordinaire).
    pub port: u16,
    /// TLS vérifié par les autorités de `webpki-roots`.
    pub tls: RelayTls,
    /// Chemin `lyxal_secrets` de l'installation : `{ "username": …, "password": … }` en JSON,
    /// lu à chaque nouvelle connexion ; absent : relais sans `AUTH`.
    pub credentials_path: Option<String>,
}

/// Réglage d'une destination (montée en charge d'une adresse IP neuve, domaine exigeant).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DestinationOverride {
    /// Domaine (forme ASCII, minuscules).
    pub domain: String,
    /// Connexions simultanées vers ce domaine (sinon `connections_per_destination`).
    pub connections: Option<u32>,
    /// Messages par minute vers ce domaine (aucune limite si absent).
    pub messages_per_minute: Option<u32>,
}

/// Délais du dialogue SMTP (RFC 5321 §4.5.3.2, connexion raccourcie comme Mox).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Timeouts {
    /// Connexion TCP (30 s).
    pub connect: Duration,
    /// Accueil `220` (300 s).
    pub greeting: Duration,
    /// Réponse à `EHLO` (300 s).
    pub ehlo: Duration,
    /// `STARTTLS` et poignée de main (60 s).
    pub starttls: Duration,
    /// Réponse à `MAIL FROM` (300 s).
    pub mail: Duration,
    /// Réponse à `RCPT TO` (300 s).
    pub rcpt: Duration,
    /// Réponse `354` à `DATA` (120 s).
    pub data: Duration,
    /// Écriture d'un bloc de données (180 s).
    pub data_block: Duration,
    /// Réponse à la fin des données (600 s).
    pub data_end: Duration,
}

impl Default for Timeouts {
    fn default() -> Self {
        Self {
            connect: Duration::from_secs(30),
            greeting: Duration::from_secs(300),
            ehlo: Duration::from_secs(300),
            starttls: Duration::from_secs(60),
            mail: Duration::from_secs(300),
            rcpt: Duration::from_secs(300),
            data: Duration::from_secs(120),
            data_block: Duration::from_secs(180),
            data_end: Duration::from_secs(600),
        }
    }
}

/// Réglages de l'envoi d'un nœud.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct OutboundConfig {
    /// Nom annoncé par `EHLO`, `Reporting-MTA` des avis, `Message-ID` ajoutés (`smtp.hostname`).
    pub hostname: String,
    /// Nom du nœud (réservations de la file, journal).
    pub node: String,
    /// Adresse source IPv4 des connexions.
    pub source_ipv4: Option<Ipv4Addr>,
    /// Adresse source IPv6 des connexions.
    pub source_ipv6: Option<Ipv6Addr>,
    /// Familles d'adresses, dans l'ordre essayé (IPv4 puis IPv6 par défaut).
    pub ip_families: Vec<IpFamily>,
    /// Port des MX (25 ; autre valeur : essais seulement).
    pub smtp_port: u16,
    /// Adresses privées, de boucle locale et réservées permises (essais, développement).
    pub allow_private_networks: bool,
    /// Adresses d'écoute du nœud, jamais contactées (un MX qui pointe vers nous).
    pub local_addresses: Vec<IpAddr>,
    /// TLS vers les MX.
    pub tls: OutboundTls,
    /// Connexions simultanées du nœud, toutes destinations (100 ; 1 à 10 000).
    pub max_connections: u32,
    /// Connexions simultanées par destination (4 ; 1 à 100).
    pub connections_per_destination: u32,
    /// Messages par connexion avant fermeture (100 ; 1 à 10 000).
    pub messages_per_connection: u32,
    /// Destinataires par transaction (100 ; 1 à 1 000).
    pub recipients_per_transaction: u32,
    /// Délais du dialogue.
    pub timeouts: Timeouts,
    /// Inactivité d'une connexion gardée pour le prochain envoi (60 s).
    pub idle_timeout: Duration,
    /// Réglages par destination.
    pub destinations: Vec<DestinationOverride>,
    /// Relais sortant.
    pub relay: Option<RelayConfig>,
    /// Destinataires réservés par appel de `fn::mail_queue_claim` (50 : mesure du sous-lot 6d).
    pub claim_batch: u32,
    /// Bail de réservation (600 s ; 60 à 1 800).
    pub lease: Duration,
    /// Délai laissé aux envois en cours à l'arrêt propre, avant qu'ils soient rendus (30 s).
    pub drain_timeout: Duration,
    /// Domaines des destinataires écrits en clair au journal (`log_recipient_domain = "full"`,
    /// niveau `debug`) ; sinon une empreinte courte (décision E28).
    pub log_domains: bool,
}

impl OutboundConfig {
    /// Réglages par défaut du plan pour le nom `hostname` et le nœud `node`.
    pub fn new(hostname: impl Into<String>, node: impl Into<String>) -> Self {
        Self {
            hostname: hostname.into(),
            node: node.into(),
            source_ipv4: None,
            source_ipv6: None,
            ip_families: vec![IpFamily::Ipv4, IpFamily::Ipv6],
            smtp_port: 25,
            allow_private_networks: false,
            local_addresses: Vec::new(),
            tls: OutboundTls::Opportunistic,
            max_connections: 100,
            connections_per_destination: 4,
            messages_per_connection: 100,
            recipients_per_transaction: 100,
            timeouts: Timeouts::default(),
            idle_timeout: Duration::from_secs(60),
            destinations: Vec::new(),
            relay: None,
            claim_batch: 50,
            lease: Duration::from_secs(600),
            drain_timeout: Duration::from_secs(30),
            log_domains: false,
        }
    }

    /// Contrôle des bornes du plan ; message sans donnée personnelle.
    pub fn validate(&self) -> Result<(), OutboundConfigError> {
        let invalid = |field: &'static str| Err(OutboundConfigError { field });
        if crate::auth::to_ascii_domain(&self.hostname).is_none_or(|name| name != self.hostname) {
            return invalid("smtp.hostname");
        }
        if self.node.is_empty() || self.node.len() > 128 || !self.node.is_ascii() {
            return invalid("node");
        }
        if self.ip_families.is_empty() || self.ip_families.len() > 2 {
            return invalid("outbound.ip_families");
        }
        if self.ip_families.len() == 2 && self.ip_families[0] == self.ip_families[1] {
            return invalid("outbound.ip_families");
        }
        if self.smtp_port == 0 {
            return invalid("outbound.smtp_port");
        }
        let within = |value: u32, low: u32, high: u32| (low..=high).contains(&value);
        if !within(self.max_connections, 1, 10_000) {
            return invalid("outbound.max_connections");
        }
        if !within(self.connections_per_destination, 1, 100) {
            return invalid("outbound.connections_per_destination");
        }
        if !within(self.messages_per_connection, 1, 10_000) {
            return invalid("outbound.messages_per_connection");
        }
        if !within(self.recipients_per_transaction, 1, 1_000) {
            return invalid("outbound.recipients_per_transaction");
        }
        if !within(self.claim_batch, 1, 500) {
            return invalid("outbound.claim_batch");
        }
        let seconds = self.lease.as_secs();
        if !(60..=1_800).contains(&seconds) {
            return invalid("outbound.lease_seconds");
        }
        let t = &self.timeouts;
        for (field, value) in [
            ("outbound.connect_timeout_seconds", t.connect),
            ("outbound.greeting_timeout_seconds", t.greeting),
            ("outbound.ehlo_timeout_seconds", t.ehlo),
            ("outbound.starttls_timeout_seconds", t.starttls),
            ("outbound.mail_timeout_seconds", t.mail),
            ("outbound.rcpt_timeout_seconds", t.rcpt),
            ("outbound.data_timeout_seconds", t.data),
            ("outbound.data_block_timeout_seconds", t.data_block),
            ("outbound.data_end_timeout_seconds", t.data_end),
            ("outbound.idle_timeout_seconds", self.idle_timeout),
        ] {
            if value.is_zero() || value > Duration::from_secs(3_600) {
                return Err(OutboundConfigError { field });
            }
        }
        let mut seen = std::collections::HashSet::new();
        for destination in &self.destinations {
            let ascii = crate::auth::to_ascii_domain(&destination.domain);
            if ascii.as_deref() != Some(destination.domain.as_str())
                || !seen.insert(destination.domain.clone())
            {
                return invalid("outbound.destinations.domain");
            }
            if destination
                .connections
                .is_some_and(|value| !within(value, 1, 100))
            {
                return invalid("outbound.destinations.connections");
            }
            if destination
                .messages_per_minute
                .is_some_and(|value| !within(value, 1, 100_000))
            {
                return invalid("outbound.destinations.messages_per_minute");
            }
        }
        if let Some(relay) = &self.relay {
            if crate::auth::to_ascii_domain(&relay.host).as_deref() != Some(relay.host.as_str()) {
                return invalid("outbound.relay.host");
            }
            if relay.port == 0 {
                return invalid("outbound.relay.port");
            }
            if relay
                .credentials_path
                .as_ref()
                .is_some_and(|path| path.is_empty() || path.len() > 256)
            {
                return invalid("outbound.relay.credentials_path");
            }
        }
        Ok(())
    }

    /// Réglage propre à une destination, s'il y en a un.
    pub fn destination(&self, domain: &str) -> Option<&DestinationOverride> {
        self.destinations
            .iter()
            .find(|destination| destination.domain == domain)
    }
}

/// Réglage hors de ses bornes (nom du réglage seulement).
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
#[error("réglage invalide : {field}")]
pub struct OutboundConfigError {
    /// Réglage en cause.
    pub field: &'static str,
}

impl fmt::Display for IpFamily {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Self::Ipv4 => "ipv4",
            Self::Ipv6 => "ipv6",
        })
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;

    #[test]
    fn defaults_are_valid_and_bounds_are_enforced() {
        let config = OutboundConfig::new("mx.alpha.test", "n1");
        assert_eq!(config.validate(), Ok(()));
        let mut bad = config.clone();
        bad.max_connections = 0;
        assert_eq!(
            bad.validate().unwrap_err().field,
            "outbound.max_connections"
        );
        let mut bad = config.clone();
        bad.hostname = "Mx.Alpha.Test".into();
        assert_eq!(bad.validate().unwrap_err().field, "smtp.hostname");
        let mut bad = config.clone();
        bad.ip_families = vec![IpFamily::Ipv6, IpFamily::Ipv6];
        assert!(bad.validate().is_err());
        let mut bad = config.clone();
        bad.destinations = vec![
            DestinationOverride {
                domain: "gmail.com".into(),
                connections: Some(2),
                messages_per_minute: None,
            },
            DestinationOverride {
                domain: "gmail.com".into(),
                connections: None,
                messages_per_minute: Some(10),
            },
        ];
        assert_eq!(
            bad.validate().unwrap_err().field,
            "outbound.destinations.domain"
        );
        let mut bad = config;
        bad.lease = Duration::from_secs(30);
        assert!(bad.validate().is_err());
    }
}
