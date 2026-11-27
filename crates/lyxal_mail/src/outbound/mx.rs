// SPDX-License-Identifier: AGPL-3.0-only

//! Serveurs d'une destination (plan du lot 6, §6.1, décision E8) : MX par le résolveur du nœud
//! ([`MailResolver`], cache du lot 5), triés par préférence et mélangés entre préférences égales
//! (RFC 5321 §5.1), 5 MX et 2 adresses par MX au plus (valeurs de Stalwart) ; MX implicite (le
//! domaine lui-même) sans enregistrement MX ; « MX nul » (RFC 7505) et domaine inexistant :
//! échec définitif ; panne du DNS : nouvel essai. Les adresses privées, de boucle locale,
//! réservées et celles du nœud sont refusées hors essais : un MX qui y pointe est une erreur de
//! configuration du destinataire, réessayée (il peut la corriger).

use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

use crate::dns::{DnsError, MailResolver, MxRecord};
use crate::outbound::config::{IpFamily, OutboundConfig};

/// MX gardés au plus par destination.
pub const MAX_MX_HOSTS: usize = 5;
/// Adresses gardées au plus par MX.
pub const MAX_ADDRESSES_PER_HOST: usize = 2;

/// Serveur à essayer : nom (SNI, journal) et adresses dans l'ordre.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MxHost {
    /// Nom du serveur (minuscules, sans point final).
    pub name: String,
    /// Adresses permises, dans l'ordre des familles réglées.
    pub addresses: Vec<IpAddr>,
}

/// Échec de la résolution d'une destination.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct ResolveFailure {
    /// Échec définitif (destinataires en échec, avis).
    pub permanent: bool,
    /// Code étendu (RFC 3463).
    pub enhanced: &'static str,
    /// Motif, pour le journal et les mesures.
    pub reason: ResolveReason,
}

/// Motif d'un échec de résolution.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ResolveReason {
    /// « MX nul » : le domaine ne reçoit pas de courrier (RFC 7505).
    NullMx,
    /// Domaine inexistant, ou sans MX ni adresse.
    NoSuchDomain,
    /// Panne du DNS.
    DnsFailure,
    /// Toutes les adresses sont interdites (privées, réservées, nôtres).
    ForbiddenAddress,
}

impl ResolveReason {
    /// Nom du motif.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::NullMx => "null_mx",
            Self::NoSuchDomain => "no_such_domain",
            Self::DnsFailure => "dns_failure",
            Self::ForbiddenAddress => "forbidden_address",
        }
    }
}

/// Plan de connexion d'une destination.
pub struct MxPlan<'a> {
    resolver: &'a dyn MailResolver,
    config: &'a OutboundConfig,
}

impl<'a> MxPlan<'a> {
    /// Plan sur le résolveur du nœud et ses réglages.
    pub fn new(resolver: &'a dyn MailResolver, config: &'a OutboundConfig) -> Self {
        Self { resolver, config }
    }

    /// Serveurs du domaine `domain` (forme ASCII), dans l'ordre d'essai.
    pub async fn resolve(&self, domain: &str) -> Result<Vec<MxHost>, ResolveFailure> {
        let names = match self.resolver.mx(domain).await {
            Ok(answer) => order_mx(answer.records)?,
            // Aucun MX : MX implicite, le domaine lui-même (RFC 5321 §5.1)
            Err(DnsError::NoRecords) => vec![domain.to_string()],
            Err(DnsError::NotFound | DnsError::InvalidName) => {
                return Err(failure(true, "5.1.2", ResolveReason::NoSuchDomain))
            }
            Err(DnsError::Temporary | DnsError::Refused) => {
                return Err(failure(false, "4.4.3", ResolveReason::DnsFailure))
            }
        };
        let implicit = names.len() == 1 && names[0] == domain;
        let mut hosts = Vec::with_capacity(names.len());
        let mut temporary = false;
        let mut forbidden = false;
        for name in names {
            let mut addresses = Vec::new();
            for family in &self.config.ip_families {
                let found: Result<Vec<IpAddr>, DnsError> = match family {
                    IpFamily::Ipv4 => self
                        .resolver
                        .ipv4(&name)
                        .await
                        .map(|answer| answer.records.into_iter().map(IpAddr::V4).collect()),
                    IpFamily::Ipv6 => self
                        .resolver
                        .ipv6(&name)
                        .await
                        .map(|answer| answer.records.into_iter().map(IpAddr::V6).collect()),
                };
                match found {
                    Ok(found) => {
                        for ip in found {
                            if !self.allowed(ip) {
                                forbidden = true;
                            } else if !addresses.contains(&ip) {
                                addresses.push(ip);
                            }
                        }
                    }
                    Err(error) if error.is_temporary() => temporary = true,
                    Err(_) => {}
                }
            }
            addresses.truncate(MAX_ADDRESSES_PER_HOST);
            if !addresses.is_empty() {
                hosts.push(MxHost { name, addresses });
            }
        }
        if !hosts.is_empty() {
            return Ok(hosts);
        }
        if temporary {
            Err(failure(false, "4.4.3", ResolveReason::DnsFailure))
        } else if forbidden {
            Err(failure(false, "4.4.4", ResolveReason::ForbiddenAddress))
        } else if implicit {
            Err(failure(true, "5.1.2", ResolveReason::NoSuchDomain))
        } else {
            // MX sans aucune adresse : configuration du destinataire, réessayée
            Err(failure(false, "4.4.4", ResolveReason::NoSuchDomain))
        }
    }

    /// Adresse permise : jamais une adresse du nœud ; hors essais, aucune adresse privée,
    /// de boucle locale, de lien local, réservée ou de multidiffusion.
    pub fn allowed(&self, ip: IpAddr) -> bool {
        let ip = canonical(ip);
        if self
            .config
            .local_addresses
            .iter()
            .any(|own| canonical(*own) == ip)
        {
            return false;
        }
        self.config.allow_private_networks || is_public(ip)
    }
}

fn failure(permanent: bool, enhanced: &'static str, reason: ResolveReason) -> ResolveFailure {
    ResolveFailure {
        permanent,
        enhanced,
        reason,
    }
}

/// MX dans l'ordre d'essai ; « MX nul » seul : échec définitif `5.1.10` (RFC 7505 §3).
fn order_mx(mut records: Vec<MxRecord>) -> Result<Vec<String>, ResolveFailure> {
    if records.iter().any(|record| record.exchange.is_empty()) {
        return Err(failure(true, "5.1.10", ResolveReason::NullMx));
    }
    // Mélange entre préférences égales (RFC 5321 §5.1), puis tri stable par préférence
    fastrand::shuffle(&mut records);
    records.sort_by_key(|record| record.preference);
    let mut names: Vec<String> = Vec::with_capacity(MAX_MX_HOSTS);
    for record in records {
        let name = record.exchange.trim_end_matches('.').to_ascii_lowercase();
        if !names.contains(&name) {
            names.push(name);
        }
        if names.len() == MAX_MX_HOSTS {
            break;
        }
    }
    Ok(names)
}

/// Adresse IPv4 dans IPv6 (`::ffff:a.b.c.d`) ramenée à IPv4.
fn canonical(ip: IpAddr) -> IpAddr {
    match ip {
        IpAddr::V6(v6) => v6.to_ipv4_mapped().map_or(ip, IpAddr::V4),
        IpAddr::V4(_) => ip,
    }
}

/// Adresse joignable sur Internet : ni privée, ni de boucle locale, ni de lien local, ni
/// réservée, ni de documentation, ni de multidiffusion.
pub fn is_public(ip: IpAddr) -> bool {
    match canonical(ip) {
        IpAddr::V4(v4) => is_public_v4(v4),
        IpAddr::V6(v6) => is_public_v6(v6),
    }
}

fn is_public_v4(ip: Ipv4Addr) -> bool {
    let [a, b, c, _] = ip.octets();
    !(ip.is_unspecified()
        || ip.is_loopback()
        || ip.is_private()
        || ip.is_link_local()
        || ip.is_broadcast()
        || ip.is_multicast()
        || ip.is_documentation()
        || a == 0
        // Partage d'adresses des opérateurs (RFC 6598)
        || (a == 100 && (64..128).contains(&b))
        // Affectations de protocole de l'IETF (RFC 6890)
        || (a == 192 && b == 0 && c == 0)
        // Bancs d'essai (RFC 2544)
        || (a == 198 && (b == 18 || b == 19))
        // Réservées (RFC 1112)
        || a >= 240)
}

fn is_public_v6(ip: Ipv6Addr) -> bool {
    let segments = ip.segments();
    !(ip.is_unspecified()
        || ip.is_loopback()
        || ip.is_multicast()
        // Adresses locales uniques (fc00::/7) et de lien local (fe80::/10)
        || (segments[0] & 0xfe00) == 0xfc00
        || (segments[0] & 0xffc0) == 0xfe80
        // Documentation (2001:db8::/32)
        || (segments[0] == 0x2001 && segments[1] == 0x0db8)
        // Traduction et anciennes formes (::/96, 64:ff9b:1::/48, 100::/64)
        || (segments[0] == 0 && segments[1] == 0 && segments[2] == 0 && segments[3] == 0)
        || segments[0] == 0x0100)
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use crate::dns::{StaticRecordType, StaticResolver};

    fn config() -> OutboundConfig {
        OutboundConfig::new("mx.lyxal.test", "n1")
    }

    #[test]
    fn public_addresses_are_told_apart() {
        for private in [
            "127.0.0.1",
            "10.1.2.3",
            "172.16.0.1",
            "192.168.1.1",
            "169.254.0.1",
            "100.64.0.1",
            "192.0.2.10",
            "0.1.2.3",
            "240.0.0.1",
            "224.0.0.1",
            "::1",
            "fd00::1",
            "fe80::1",
            "2001:db8::1",
            "::ffff:10.0.0.1",
        ] {
            assert!(!is_public(private.parse().unwrap()), "{private}");
        }
        for public in ["8.8.8.8", "185.12.64.1", "2a00:1450:4007::1b"] {
            assert!(is_public(public.parse().unwrap()), "{public}");
        }
    }

    fn ip(text: &str) -> IpAddr {
        text.parse().unwrap()
    }

    #[tokio::test]
    async fn mx_records_are_ordered_and_addresses_filtered() {
        let mut resolver = StaticResolver::new();
        resolver
            .set_mx("dest.test", &[(20, "b.dest.test"), (10, "a.dest.test")])
            .set_ips("a.dest.test", &[ip("10.0.0.1")])
            .set_ips("b.dest.test", &[ip("8.8.4.4"), ip("2a00:1450:4007::1b")]);
        let config = config();
        let hosts = MxPlan::new(&resolver, &config)
            .resolve("dest.test")
            .await
            .unwrap();
        assert_eq!(
            hosts.len(),
            1,
            "l'adresse privée de a.dest.test est écartée"
        );
        assert_eq!(hosts[0].name, "b.dest.test");
        assert_eq!(hosts[0].addresses.len(), 2);
        assert!(hosts[0].addresses[0].is_ipv4(), "IPv4 d'abord");
        let mut testing = config.clone();
        testing.allow_private_networks = true;
        let hosts = MxPlan::new(&resolver, &testing)
            .resolve("dest.test")
            .await
            .unwrap();
        assert_eq!(
            hosts[0].name, "a.dest.test",
            "préférence la plus petite d'abord"
        );
        testing.local_addresses = vec![ip("10.0.0.1")];
        let hosts = MxPlan::new(&resolver, &testing)
            .resolve("dest.test")
            .await
            .unwrap();
        assert_eq!(
            hosts[0].name, "b.dest.test",
            "nos propres adresses jamais contactées"
        );
    }

    #[tokio::test]
    async fn null_mx_absent_domain_and_dns_failure_are_classified() {
        let mut resolver = StaticResolver::new();
        resolver
            .set_mx("null.test", &[(0, ".")])
            .fail(StaticRecordType::Mx, "panne.test")
            .set_ips("implicite.test", &[ip("8.8.8.8")])
            .set_mx("prive.test", &[(10, "mx.prive.test")])
            .set_ips("mx.prive.test", &[ip("192.168.0.2")]);
        let config = config();
        let plan = MxPlan::new(&resolver, &config);
        let null = plan.resolve("null.test").await.unwrap_err();
        assert_eq!((null.permanent, null.enhanced), (true, "5.1.10"));
        let absent = plan.resolve("absent.test").await.unwrap_err();
        assert_eq!((absent.permanent, absent.enhanced), (true, "5.1.2"));
        let down = plan.resolve("panne.test").await.unwrap_err();
        assert!(!down.permanent);
        assert_eq!(down.reason, ResolveReason::DnsFailure);
        let implicit = plan.resolve("implicite.test").await.unwrap();
        assert_eq!(implicit[0].name, "implicite.test");
        let private = plan.resolve("prive.test").await.unwrap_err();
        assert_eq!(
            (private.permanent, private.reason),
            (false, ResolveReason::ForbiddenAddress)
        );
    }
}
