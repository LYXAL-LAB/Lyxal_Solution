//! Appels sortants vers une adresse choisie par une personne (messageries d'équipe, adresse web) :
//! protection contre la falsification de requêtes côté serveur (SSRF, décisions E3 et K7).
//!
//! À chaque envoi :
//! * **HTTPS seulement**, sans identifiants dans l'adresse ni adresse IP littérale ;
//! * hôte du service : hôtes **officiels** de Slack, Teams, Discord, Google Chat et Telegram ;
//!   Mattermost et adresse web : **tout hôte public**, dans la liste `allowed_hosts` de
//!   l'installation si elle est réglée ;
//! * nom **résolu à chaque envoi** et **toutes** les adresses obtenues vérifiées : refus des
//!   adresses non spécifiées, de boucle locale, privées (10/8, 172.16/12, 192.168/16), de lien
//!   local (169.254/16 : métadonnées des plateformes en nuage comprises ; fe80::/10), partagées
//!   (100.64/10), de multidiffusion, de diffusion, réservées et de documentation, IPv6 locales
//!   uniques (fc00::/7), et des adresses IPv4 portées par IPv6 (mappées, compatibles, NAT64, 6to4) ;
//! * connexion faite **à l'adresse vérifiée** (`resolve_to_addrs` : aucune seconde résolution,
//!   pas de « rebinding »), sans mandataire ;
//! * **aucune redirection** suivie, délai de 10 s, réponse lue sur 64 Kio au plus.
//!
//! Les tests remplacent la résolution par une table (`StaticResolver`) et
//! [`OutboundClient::for_local_tests`] autorise la seule boucle locale, où les faux services
//! écoutent en HTTP ; tous les autres contrôles restent appliqués.

use async_trait::async_trait;
use reqwest::header::{HeaderMap, HeaderValue, ACCEPT, CONTENT_TYPE};
use reqwest::redirect::Policy;
use reqwest::{Client, Url};
use std::collections::HashMap;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr};
use std::sync::Arc;
use std::time::Duration;

use crate::provider::{ProviderError, REQUEST_TIMEOUT};

/// Résolution d'un nom d'hôte.
#[async_trait]
pub trait HostResolver: Send + Sync {
    /// Adresses de `host` pour le port `port`.
    async fn lookup(&self, host: &str, port: u16) -> std::io::Result<Vec<SocketAddr>>;
}

/// Résolution du système (production).
#[derive(Debug, Clone, Copy, Default)]
pub struct SystemResolver;

#[async_trait]
impl HostResolver for SystemResolver {
    async fn lookup(&self, host: &str, port: u16) -> std::io::Result<Vec<SocketAddr>> {
        Ok(tokio::net::lookup_host((host, port)).await?.collect())
    }
}

/// Table de résolution des tests : nom → adresses (avec le port du faux service).
#[derive(Debug, Clone, Default)]
pub struct StaticResolver {
    entries: HashMap<String, Vec<SocketAddr>>,
}

impl StaticResolver {
    /// Table vide.
    pub fn new() -> Self {
        Self::default()
    }

    /// `host` se résout en `address`.
    pub fn with(mut self, host: &str, address: SocketAddr) -> Self {
        self.entries
            .entry(host.to_ascii_lowercase())
            .or_default()
            .push(address);
        self
    }
}

#[async_trait]
impl HostResolver for StaticResolver {
    async fn lookup(&self, host: &str, _port: u16) -> std::io::Result<Vec<SocketAddr>> {
        self.entries
            .get(&host.to_ascii_lowercase())
            .cloned()
            .ok_or_else(|| std::io::Error::new(std::io::ErrorKind::NotFound, "nom inconnu"))
    }
}

/// Hôtes acceptés pour un service.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HostRule {
    /// Hôtes officiels : noms exacts et suffixes (`.webhook.office.com`).
    Official {
        /// Noms exacts.
        exact: &'static [&'static str],
        /// Suffixes (avec leur point initial).
        suffixes: &'static [&'static str],
    },
    /// Tout hôte public, dans la liste de l'installation si elle est réglée.
    AnyPublic,
}

impl HostRule {
    /// L'hôte (en minuscules) est-il accepté ?
    pub fn accepts(self, host: &str, allowed_hosts: &[String]) -> bool {
        match self {
            Self::Official { exact, suffixes } => {
                exact.contains(&host) || suffixes.iter().any(|suffix| host.ends_with(suffix))
            }
            Self::AnyPublic => {
                allowed_hosts.is_empty() || allowed_hosts.iter().any(|allowed| allowed == host)
            }
        }
    }
}

/// Adresse interdite : non publique (boucle locale, privée, lien local, partagée, multidiffusion,
/// diffusion, réservée, documentation), ou adresse IPv4 interdite portée par IPv6.
pub fn forbidden_ip(ip: IpAddr) -> bool {
    match ip {
        IpAddr::V4(v4) => forbidden_v4(v4),
        IpAddr::V6(v6) => forbidden_v6(v6),
    }
}

fn forbidden_v4(ip: Ipv4Addr) -> bool {
    let [a, b, c, _] = ip.octets();
    ip.is_unspecified()
        || a == 0 // « ce réseau » 0.0.0.0/8
        || ip.is_loopback() // 127/8
        || ip.is_private() // 10/8, 172.16/12, 192.168/16
        || ip.is_link_local() // 169.254/16 (métadonnées des plateformes)
        || (a == 100 && (64..=127).contains(&b)) // partagée 100.64/10
        || ip.is_multicast() // 224/4
        || ip.is_broadcast()
        || a >= 240 // réservée 240/4
        || (a == 192 && b == 0 && c == 0) // affectations IETF 192.0.0/24
        || (a == 192 && b == 0 && c == 2) // documentation 192.0.2/24
        || (a == 198 && b == 51 && c == 100) // documentation 198.51.100/24
        || (a == 203 && b == 0 && c == 113) // documentation 203.0.113/24
        || (a == 198 && (b == 18 || b == 19)) // essais de performance 198.18/15
        || (a == 192 && b == 88 && c == 99) // relais 6to4 192.88.99/24
}

fn forbidden_v6(ip: Ipv6Addr) -> bool {
    let segments = ip.segments();
    // Adresse IPv4 portée par IPv6 : mappée (::ffff:a.b.c.d), compatible (::a.b.c.d), NAT64
    // (64:ff9b::/96), 6to4 (2002::/16) : jugée comme l'adresse IPv4
    if let Some(v4) = ip.to_ipv4_mapped() {
        return forbidden_v4(v4);
    }
    if segments[..6] == [0, 0, 0, 0, 0, 0] && !ip.is_unspecified() && !ip.is_loopback() {
        return forbidden_v4(Ipv4Addr::from(
            (u32::from(segments[6]) << 16) | u32::from(segments[7]),
        ));
    }
    if segments[..6] == [0x64, 0xff9b, 0, 0, 0, 0] {
        return forbidden_v4(Ipv4Addr::from(
            (u32::from(segments[6]) << 16) | u32::from(segments[7]),
        ));
    }
    if segments[0] == 0x2002 {
        return forbidden_v4(Ipv4Addr::from(
            (u32::from(segments[1]) << 16) | u32::from(segments[2]),
        ));
    }
    ip.is_unspecified() // ::
        || ip.is_loopback() // ::1
        || ip.is_multicast() // ff00::/8
        || (segments[0] & 0xfe00) == 0xfc00 // locale unique fc00::/7
        || (segments[0] & 0xffc0) == 0xfe80 // lien local fe80::/10
        || (segments[0] & 0xffc0) == 0xfec0 // site local (obsolète) fec0::/10
        || (segments[0] == 0x2001 && segments[1] == 0x0db8) // documentation 2001:db8::/32
        || (segments[0] == 0x2001 && segments[1] == 0) // Teredo 2001::/32
        || segments[..4] == [0x0100, 0, 0, 0] // rejet 100::/64
}

/// Réponse d'un appel sortant.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OutboundResponse {
    /// Code HTTP.
    pub status: u16,
    /// Corps (64 Kio au plus ; absent au-delà ou en cas d'erreur de lecture).
    pub body: Option<Vec<u8>>,
}

/// Client des appels sortants contrôlés.
pub struct OutboundClient {
    resolver: Arc<dyn HostResolver>,
    local_tests: bool,
    timeout: Duration,
}

impl std::fmt::Debug for OutboundClient {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("OutboundClient")
            .field("local_tests", &self.local_tests)
            .finish_non_exhaustive()
    }
}

impl Default for OutboundClient {
    fn default() -> Self {
        Self::new()
    }
}

/// Refus d'une destination.
fn forbidden(detail: &str) -> ProviderError {
    ProviderError {
        class: crate::models::FailureClass::Permanent,
        code: "NOTIFICATION_DESTINATION_FORBIDDEN".to_string(),
        detail: detail.to_string(),
    }
}

impl OutboundClient {
    /// Client de production : résolution du système, HTTPS seulement.
    pub fn new() -> Self {
        Self {
            resolver: Arc::new(SystemResolver),
            local_tests: false,
            timeout: REQUEST_TIMEOUT,
        }
    }

    /// Réservé aux tests : noms résolus par `resolver` ; seule la boucle locale est permise en
    /// plus des adresses publiques, et l'appel d'une adresse `https://` est fait en HTTP vers le
    /// faux service local. Tous les autres contrôles restent appliqués.
    pub fn for_local_tests(resolver: StaticResolver) -> Self {
        Self {
            resolver: Arc::new(resolver),
            local_tests: true,
            timeout: Duration::from_secs(5),
        }
    }

    /// Vérifie l'adresse, résout son hôte, vérifie chaque adresse obtenue et poste le corps JSON
    /// à l'adresse vérifiée. Refus : `NOTIFICATION_DESTINATION_FORBIDDEN` (définitif) ; nom
    /// introuvable, réseau ou délai : temporaire.
    pub async fn post_json(
        &self,
        url: &str,
        rule: HostRule,
        allowed_hosts: &[String],
        headers: HeaderMap,
        body: Vec<u8>,
    ) -> Result<OutboundResponse, ProviderError> {
        let (mut target, host, port) = self.vet_url(url, rule, allowed_hosts)?;
        let addresses = self.resolve(&host, port).await?;
        if self.local_tests {
            // Faux service local en HTTP : même chemin, même hôte annoncé
            target
                .set_scheme("http")
                .map_err(|_| ProviderError::configuration("adresse de test invalide"))?;
        }
        let client = Client::builder()
            .use_rustls_tls()
            .https_only(!self.local_tests)
            .redirect(Policy::none())
            .no_proxy()
            .timeout(self.timeout)
            .connect_timeout(self.timeout)
            .resolve_to_addrs(&host, &addresses)
            .user_agent("lyxal-notification")
            .build()
            .map_err(|_| ProviderError::configuration("client HTTP impossible"))?;
        let response = client
            .post(target)
            .headers(headers)
            .header(CONTENT_TYPE, HeaderValue::from_static("application/json"))
            .header(ACCEPT, HeaderValue::from_static("application/json"))
            .body(body)
            .send()
            .await
            .map_err(|error| {
                // L'erreur n'est jamais affichée : elle peut contenir l'adresse (un secret)
                if error.is_timeout() {
                    ProviderError::unavailable("délai dépassé")
                } else if error.is_builder() {
                    ProviderError::configuration("requête refusée avant l'envoi")
                } else {
                    ProviderError::unavailable("service injoignable")
                }
            })?;
        let status = response.status().as_u16();
        Ok(OutboundResponse {
            status,
            body: crate::provider::read_bounded(response).await,
        })
    }

    /// Contrôles de l'adresse avant toute résolution : HTTPS, ni identifiants ni adresse IP,
    /// hôte accepté par le service.
    fn vet_url(
        &self,
        url: &str,
        rule: HostRule,
        allowed_hosts: &[String],
    ) -> Result<(Url, String, u16), ProviderError> {
        let target = Url::parse(url).map_err(|_| forbidden("adresse illisible"))?;
        if target.scheme() != "https" {
            return Err(forbidden("HTTPS seulement"));
        }
        if !target.username().is_empty() || target.password().is_some() {
            return Err(forbidden("identifiants dans l'adresse"));
        }
        let host = target
            .host_str()
            .filter(|host| !host.is_empty())
            .ok_or_else(|| forbidden("hôte absent"))?
            .to_ascii_lowercase();
        if host
            .trim_start_matches('[')
            .trim_end_matches(']')
            .parse::<IpAddr>()
            .is_ok()
        {
            return Err(forbidden("adresse IP littérale"));
        }
        if !rule.accepts(&host, allowed_hosts) {
            return Err(forbidden("hôte non autorisé pour ce service"));
        }
        let port = target.port_or_known_default().unwrap_or(443);
        Ok((target, host, port))
    }

    /// Résout le nom et vérifie chaque adresse : une seule adresse interdite refuse l'hôte.
    async fn resolve(&self, host: &str, port: u16) -> Result<Vec<SocketAddr>, ProviderError> {
        let addresses = tokio::time::timeout(self.timeout, self.resolver.lookup(host, port))
            .await
            .map_err(|_| ProviderError::unavailable("résolution trop longue"))?
            .map_err(|_| ProviderError::unavailable("nom introuvable"))?;
        if addresses.is_empty() {
            return Err(ProviderError::unavailable("nom introuvable"));
        }
        let allowed = |address: &SocketAddr| {
            let ip = address.ip();
            !forbidden_ip(ip) || (self.local_tests && ip.is_loopback())
        };
        if !addresses.iter().all(allowed) {
            return Err(forbidden("adresse résolue privée, locale ou réservée"));
        }
        Ok(addresses)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ip(text: &str) -> IpAddr {
        text.parse().expect("adresse")
    }

    #[test]
    fn non_public_addresses_are_forbidden() {
        for refused in [
            "0.0.0.0",
            "0.1.2.3",
            "127.0.0.1",
            "10.1.2.3",
            "172.16.0.1",
            "172.31.255.255",
            "192.168.1.1",
            "169.254.169.254",
            "100.64.0.1",
            "100.127.255.254",
            "224.0.0.1",
            "255.255.255.255",
            "240.0.0.1",
            "192.0.0.8",
            "192.0.2.10",
            "198.51.100.7",
            "203.0.113.9",
            "198.18.0.1",
            "::",
            "::1",
            "fc00::1",
            "fd12:3456::1",
            "fe80::1",
            "fec0::1",
            "ff02::1",
            "2001:db8::1",
            "::ffff:10.0.0.1",
            "::ffff:127.0.0.1",
            "::ffff:169.254.169.254",
            "::10.0.0.1",
            "64:ff9b::a00:1",
            "2002:a00:1::1",
            "2001::1",
        ] {
            assert!(forbidden_ip(ip(refused)), "{refused}");
        }
        for accepted in [
            "8.8.8.8",
            "1.1.1.1",
            "100.63.255.255",
            "100.128.0.1",
            "172.32.0.1",
            "2606:4700:4700::1111",
            "2a00:1450:4007:80e::200e",
            "::ffff:8.8.8.8",
            "64:ff9b::808:808",
        ] {
            assert!(!forbidden_ip(ip(accepted)), "{accepted}");
        }
    }

    #[test]
    fn host_rules() {
        let slack = HostRule::Official {
            exact: &["hooks.slack.com"],
            suffixes: &[],
        };
        assert!(slack.accepts("hooks.slack.com", &[]));
        assert!(!slack.accepts("hooks.slack.com.pirate.test", &[]));
        let teams = HostRule::Official {
            exact: &[],
            suffixes: &[".webhook.office.com"],
        };
        assert!(teams.accepts("alpha.webhook.office.com", &[]));
        assert!(!teams.accepts("webhook.office.com.pirate.test", &[]));
        assert!(HostRule::AnyPublic.accepts("crm.exemple.fr", &[]));
        let allowed = vec!["hooks.exemple.fr".to_string()];
        assert!(HostRule::AnyPublic.accepts("hooks.exemple.fr", &allowed));
        assert!(!HostRule::AnyPublic.accepts("crm.exemple.fr", &allowed));
    }

    #[tokio::test]
    async fn urls_are_vetted_before_any_call() {
        let client = OutboundClient::for_local_tests(StaticResolver::new());
        for (url, rule) in [
            ("http://crm.exemple.fr/x", HostRule::AnyPublic),
            ("https://10.0.0.5/x", HostRule::AnyPublic),
            ("https://[fd00::1]/x", HostRule::AnyPublic),
            ("https://user:pass@crm.exemple.fr/x", HostRule::AnyPublic),
            (
                "https://evil.test/x",
                HostRule::Official {
                    exact: &["hooks.slack.com"],
                    suffixes: &[],
                },
            ),
        ] {
            let error = client
                .post_json(url, rule, &[], HeaderMap::new(), Vec::new())
                .await
                .expect_err(url);
            assert_eq!(error.code, "NOTIFICATION_DESTINATION_FORBIDDEN", "{url}");
            assert_eq!(error.class, crate::models::FailureClass::Permanent);
        }
        // Nom inconnu : temporaire (une résolution peut réussir plus tard)
        let error = client
            .post_json(
                "https://inconnu.exemple.fr/x",
                HostRule::AnyPublic,
                &[],
                HeaderMap::new(),
                Vec::new(),
            )
            .await
            .expect_err("nom inconnu");
        assert_eq!(error.code, "NOTIFICATION_PROVIDER_UNAVAILABLE");
    }
}
