//! Adresse réelle du client derrière des proxys inverses de confiance (`server.trusted_proxies`).
//!
//! L'adresse est lue dans `X-Forwarded-For` seulement si la connexion vient d'un proxy de
//! confiance : on prend l'adresse la plus à droite qui n'est pas elle-même un proxy de confiance
//! (les adresses de gauche sont écrites par le client et ne prouvent rien). Sans proxy de
//! confiance, ou si l'en-tête est absent ou illisible, c'est l'adresse de la connexion.

use serde::{Deserialize, Deserializer};
use std::fmt;
use std::net::IpAddr;
use std::str::FromStr;

/// Réseau d'adresses (`192.0.2.10`, `10.0.0.0/8`, `2001:db8::/32`).
#[derive(Clone, Copy, PartialEq, Eq)]
pub struct IpNetwork {
    address: IpAddr,
    prefix: u8,
}

impl IpNetwork {
    /// Vrai si `ip` appartient au réseau (même famille d'adresses, même préfixe).
    pub fn contains(&self, ip: IpAddr) -> bool {
        match (self.address, normalize(ip)) {
            (IpAddr::V4(net), IpAddr::V4(ip)) => {
                prefix_matches(&net.octets(), &ip.octets(), self.prefix)
            }
            (IpAddr::V6(net), IpAddr::V6(ip)) => {
                prefix_matches(&net.octets(), &ip.octets(), self.prefix)
            }
            _ => false,
        }
    }
}

/// Adresse IPv4 transportée en IPv6 (`::ffff:a.b.c.d`) ramenée à l'IPv4.
fn normalize(ip: IpAddr) -> IpAddr {
    match ip {
        IpAddr::V6(v6) => v6
            .to_ipv4_mapped()
            .map(IpAddr::V4)
            .unwrap_or(IpAddr::V6(v6)),
        v4 => v4,
    }
}

fn prefix_matches(net: &[u8], ip: &[u8], prefix: u8) -> bool {
    let full = usize::from(prefix / 8);
    let rest = prefix % 8;
    if net[..full] != ip[..full] {
        return false;
    }
    if rest == 0 {
        return true;
    }
    let mask = 0xffu8 << (8 - rest);
    (net[full] & mask) == (ip[full] & mask)
}

impl FromStr for IpNetwork {
    type Err = String;

    fn from_str(text: &str) -> Result<Self, Self::Err> {
        let invalid = || format!("réseau invalide « {text} » (adresse IP ou adresse/préfixe)");
        let (address, prefix) = match text.trim().split_once('/') {
            Some((address, prefix)) => (address, Some(prefix)),
            None => (text.trim(), None),
        };
        let address = normalize(IpAddr::from_str(address).map_err(|_| invalid())?);
        let max = if address.is_ipv4() { 32 } else { 128 };
        let prefix = match prefix {
            Some(prefix) => prefix.parse::<u8>().map_err(|_| invalid())?,
            None => max,
        };
        if prefix > max {
            return Err(invalid());
        }
        Ok(Self { address, prefix })
    }
}

impl fmt::Debug for IpNetwork {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}/{}", self.address, self.prefix)
    }
}

impl<'de> Deserialize<'de> for IpNetwork {
    fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        String::deserialize(deserializer)?
            .parse()
            .map_err(serde::de::Error::custom)
    }
}

/// Adresse du client : `peer` (adresse de la connexion), ou, si `peer` est un proxy de
/// confiance, l'adresse la plus à droite de `forwarded_for` qui n'en est pas un.
pub fn client_ip(peer: IpAddr, forwarded_for: Option<&str>, trusted: &[IpNetwork]) -> IpAddr {
    let peer = normalize(peer);
    let is_trusted = |ip: IpAddr| trusted.iter().any(|net| net.contains(ip));
    if !is_trusted(peer) {
        return peer;
    }
    let Some(header) = forwarded_for else {
        return peer;
    };
    let mut hops = Vec::new();
    for hop in header.split(',') {
        match IpAddr::from_str(hop.trim()) {
            Ok(ip) => hops.push(normalize(ip)),
            // En-tête illisible : on ne s'y fie pas
            Err(_) => return peer,
        }
    }
    hops.into_iter()
        .rev()
        .find(|ip| !is_trusted(*ip))
        .unwrap_or(peer)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn nets(list: &[&str]) -> Vec<IpNetwork> {
        list.iter().filter_map(|n| n.parse().ok()).collect()
    }

    fn ip(text: &str) -> IpAddr {
        IpAddr::from_str(text).unwrap_or(IpAddr::from([0, 0, 0, 0]))
    }

    #[test]
    fn networks_are_parsed_and_matched() {
        let net: IpNetwork = "10.0.0.0/8".parse().unwrap_or(IpNetwork {
            address: ip("0.0.0.0"),
            prefix: 32,
        });
        assert!(net.contains(ip("10.1.2.3")));
        assert!(!net.contains(ip("11.0.0.1")));
        assert!(net.contains(ip("::ffff:10.9.9.9")));
        assert!("192.0.2.1".parse::<IpNetwork>().is_ok());
        assert!("2001:db8::/32".parse::<IpNetwork>().is_ok());
        assert!("10.0.0.0/33".parse::<IpNetwork>().is_err());
        assert!("proxy".parse::<IpNetwork>().is_err());
        let v6: Vec<IpNetwork> = nets(&["2001:db8::/32"]);
        assert!(v6[0].contains(ip("2001:db8:1::5")));
        assert!(!v6[0].contains(ip("2001:db9::5")));
    }

    #[test]
    fn untrusted_peer_ignores_the_header() {
        let trusted = nets(&["10.0.0.0/8"]);
        assert_eq!(
            client_ip(ip("203.0.113.7"), Some("198.51.100.1"), &trusted),
            ip("203.0.113.7")
        );
        assert_eq!(
            client_ip(ip("10.0.0.2"), Some("198.51.100.1"), &[]),
            ip("10.0.0.2")
        );
    }

    #[test]
    fn trusted_proxy_gives_the_rightmost_untrusted_address() {
        let trusted = nets(&["10.0.0.0/8"]);
        // Le client a forgé la première adresse ; le proxy a ajouté l'adresse réelle
        assert_eq!(
            client_ip(
                ip("10.0.0.2"),
                Some("1.1.1.1, 198.51.100.1, 10.0.0.9"),
                &trusted
            ),
            ip("198.51.100.1")
        );
        assert_eq!(client_ip(ip("10.0.0.2"), None, &trusted), ip("10.0.0.2"));
        assert_eq!(
            client_ip(ip("10.0.0.2"), Some("pas une adresse"), &trusted),
            ip("10.0.0.2")
        );
        assert_eq!(
            client_ip(ip("10.0.0.2"), Some("10.0.0.3"), &trusted),
            ip("10.0.0.2")
        );
    }
}
