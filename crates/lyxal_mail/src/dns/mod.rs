// SPDX-License-Identifier: AGPL-3.0-only

//! Résolveur DNS du courrier (plan du lot 5, §5, décision S3).
//!
//! Le trait [`MailResolver`] est la seule porte vers le DNS pour SPF, DKIM, DMARC et le nom
//! inverse ([`crate::auth`]). Deux implémentations :
//!
//! * [`HickoryResolver`] (production) : `hickory-resolver` sans DNSSEC (lot 7), **une instance
//!   par nœud**, construite par l'hôte et partagée par toutes les sessions ; cache intégré
//!   (16 384 réponses par défaut, TTL positif borné à 1 h, négatif à 5 min) ; aucun cache en
//!   base ;
//! * [`StaticResolver`] (essais) : table de réponses, pannes et délais simulés. Aucun essai
//!   automatique n'interroge le vrai DNS.
//!
//! [`DnsError`] distingue l'absence (résultat définitif : `NotFound`, `NoRecords`) de la panne
//! (`Temporary`, `Refused` : résultat `temperror` des contrôles).

mod hickory;
mod static_resolver;

use async_trait::async_trait;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

pub use hickory::{DnsConfig, DnsSetupError, HickoryResolver};
pub use static_resolver::{StaticRecordType, StaticResolver};

/// Longueur maximale d'un nom de domaine, en octets (RFC 1035 §2.3.4, sans le point final).
pub const MAX_NAME_BYTES: usize = 253;
/// Longueur maximale d'un enregistrement TXT rendu (morceaux concaténés), en octets : celle
/// d'une clé DKIM (plan du lot 5, §5). SPF et DMARC appliquent en plus leur propre borne
/// ([`MAX_POLICY_TXT_BYTES`]).
pub const MAX_TXT_BYTES: usize = 16_384;
/// Longueur maximale d'un enregistrement SPF ou DMARC (morceaux concaténés), en octets.
pub const MAX_POLICY_TXT_BYTES: usize = 4_096;
/// Nombre maximal d'enregistrements rendus par une réponse (les suivants sont ignorés).
pub const MAX_RECORDS_PER_ANSWER: usize = 64;

/// Réponse positive : au moins un enregistrement du type demandé, au plus
/// [`MAX_RECORDS_PER_ANSWER`].
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Answer<T> {
    /// Enregistrements, dans l'ordre de la réponse.
    pub records: Vec<T>,
}

/// Enregistrement MX.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MxRecord {
    /// Préférence (la plus petite d'abord).
    pub preference: u16,
    /// Nom de l'échangeur, en minuscules, sans point final ; vide pour le « MX nul » (RFC 7505).
    pub exchange: String,
}

/// Échec d'une requête DNS.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum DnsError {
    /// Le nom n'existe pas (`NXDOMAIN`) : résultat définitif.
    #[error("le nom n'existe pas")]
    NotFound,
    /// Le nom existe mais n'a aucun enregistrement du type demandé : résultat définitif.
    #[error("aucun enregistrement de ce type")]
    NoRecords,
    /// Nom illisible ou trop long : aucune requête n'est faite.
    #[error("nom de domaine invalide")]
    InvalidName,
    /// Panne (délai dépassé, `SERVFAIL`, réseau) : à réessayer plus tard.
    #[error("panne du DNS")]
    Temporary,
    /// Le serveur DNS refuse la requête (`REFUSED`) : traité comme une panne.
    #[error("requête refusée par le serveur DNS")]
    Refused,
}

impl DnsError {
    /// Vrai pour une absence définitive (`NXDOMAIN` ou aucun enregistrement) : une « réponse
    /// vide » au sens de la RFC 7208 §4.6.4.
    pub fn is_absent(&self) -> bool {
        matches!(self, Self::NotFound | Self::NoRecords)
    }

    /// Vrai pour une panne (résultat `temperror`).
    pub fn is_temporary(&self) -> bool {
        matches!(self, Self::Temporary | Self::Refused)
    }
}

/// Résultat d'une requête DNS.
pub type DnsResult<T> = Result<Answer<T>, DnsError>;

/// Lecture du DNS pour le courrier. Les noms sont des noms ASCII (A-label), avec ou sans point
/// final, toujours interrogés comme noms complets (aucun domaine de recherche ajouté).
#[async_trait]
pub trait MailResolver: Send + Sync {
    /// Enregistrements TXT du nom, chacun en une chaîne (morceaux concaténés, RFC 7208 §3.3),
    /// [`MAX_TXT_BYTES`] au plus (les plus longs sont ignorés) ; octets non UTF-8 remplacés.
    async fn txt(&self, name: &str) -> DnsResult<String>;
    /// Enregistrements MX du nom.
    async fn mx(&self, name: &str) -> DnsResult<MxRecord>;
    /// Adresses IPv4 du nom (A).
    async fn ipv4(&self, name: &str) -> DnsResult<Ipv4Addr>;
    /// Adresses IPv6 du nom (AAAA).
    async fn ipv6(&self, name: &str) -> DnsResult<Ipv6Addr>;
    /// Noms inverses d'une adresse (PTR), en minuscules, sans point final.
    async fn ptr(&self, ip: IpAddr) -> DnsResult<String>;

    /// Adresses du nom de la même famille que `like` (A pour IPv4, AAAA pour IPv6).
    async fn ips_like(&self, name: &str, like: IpAddr) -> DnsResult<IpAddr> {
        match like {
            IpAddr::V4(_) => self.ipv4(name).await.map(|answer| Answer {
                records: answer.records.into_iter().map(IpAddr::V4).collect(),
            }),
            IpAddr::V6(_) => self.ipv6(name).await.map(|answer| Answer {
                records: answer.records.into_iter().map(IpAddr::V6).collect(),
            }),
        }
    }
}

/// Nom normalisé pour une requête : minuscules, sans point final ; `None` s'il est vide, trop
/// long ou contient un octet hors de l'ASCII imprimable (les étiquettes sont contrôlées par
/// l'appelant, qui sait si le soulignement est permis).
pub(crate) fn normalize_name(name: &str) -> Option<String> {
    let trimmed = name.strip_suffix('.').unwrap_or(name);
    if trimmed.is_empty()
        || trimmed.len() > MAX_NAME_BYTES
        || !trimmed.bytes().all(|byte| byte.is_ascii_graphic())
    {
        return None;
    }
    Some(trimmed.to_ascii_lowercase())
}

/// Nom de la zone inverse d'une adresse (`in-addr.arpa` ou `ip6.arpa`), sans point final.
pub fn reverse_name(ip: IpAddr) -> String {
    match ip {
        IpAddr::V4(v4) => {
            let [a, b, c, d] = v4.octets();
            format!("{d}.{c}.{b}.{a}.in-addr.arpa")
        }
        IpAddr::V6(v6) => {
            let mut name = String::with_capacity(72);
            for byte in v6.octets().iter().rev() {
                for nibble in [byte & 0x0f, byte >> 4] {
                    name.push(char::from_digit(u32::from(nibble), 16).unwrap_or('0'));
                    name.push('.');
                }
            }
            name.push_str("ip6.arpa");
            name
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn noms_normalises() {
        assert_eq!(normalize_name("Example.COM."), Some("example.com".into()));
        assert_eq!(normalize_name(""), None);
        assert_eq!(normalize_name("."), None);
        assert_eq!(normalize_name("a b.example"), None);
        assert_eq!(normalize_name(&"a".repeat(254)), None);
        assert_eq!(normalize_name(&"a".repeat(253)), Some("a".repeat(253)));
    }

    #[test]
    fn zones_inverses() {
        assert_eq!(
            reverse_name("192.0.2.3".parse().unwrap()),
            "3.2.0.192.in-addr.arpa"
        );
        assert_eq!(
            reverse_name("2001:db8::cb01".parse().unwrap()),
            "1.0.b.c.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.8.b.d.0.1.0.0.2.ip6.arpa"
        );
    }
}
