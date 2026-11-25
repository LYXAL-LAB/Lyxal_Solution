// SPDX-License-Identifier: AGPL-3.0-only

//! SPF (RFC 7208), écrit depuis la RFC (aucune copie de `mail-auth` disponible hors ligne lors
//! du lot 5b ; voir `SOURCES.md`) ; cas d'essai transposés de Mox (`spf/spf_test.go`, MIT).
//!
//! `check_host()` (§4) sur l'identité `MAIL FROM` (ou `postmaster@<HELO>` pour un expéditeur
//! vide, §2.4) et sur l'identité HELO (§2.3) ; mécanismes `all`, `include`, `a`, `mx`, `ptr`,
//! `ip4`, `ip6`, `exists`, modificateurs `redirect` et `exp` (lu, jamais utilisé) ; macros
//! (§7) ; limites (§4.6.4) : 10 termes qui interrogent le DNS, 2 réponses vides, 10 noms par
//! `mx` (au-delà : `permerror`) ou par `ptr` (au-delà : ignorés) ; délai total de 20 s
//! (`temperror`).

mod record;

use super::domain::{is_multi_label, is_same_or_subdomain, is_valid_domain, to_ascii_domain};
use crate::dns::{DnsError, MailResolver, MAX_NAME_BYTES, MAX_POLICY_TXT_BYTES};
use record::{in_network, MacroString, MacroToken, Mechanism, Qualifier, SpfRecord};
use std::future::Future;
use std::net::IpAddr;
use std::pin::Pin;
use std::time::Duration;

/// Résultat SPF (RFC 7208 §2.6 ; mots de la RFC 8601).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum SpfResult {
    /// Aucun enregistrement, ou identité illisible.
    None,
    /// Le domaine ne se prononce pas.
    Neutral,
    /// Client autorisé.
    Pass,
    /// Client non autorisé.
    Fail,
    /// Client probablement non autorisé.
    SoftFail,
    /// Panne du DNS.
    TempError,
    /// Enregistrement inexploitable.
    PermError,
}

impl SpfResult {
    /// Mot du résultat (RFC 8601 §2.7.2).
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Neutral => "neutral",
            Self::Pass => "pass",
            Self::Fail => "fail",
            Self::SoftFail => "softfail",
            Self::TempError => "temperror",
            Self::PermError => "permerror",
        }
    }
}

/// Identité contrôlée (RFC 8601 : `smtp.mailfrom` ou `smtp.helo`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SpfIdentity {
    /// Identité `MAIL FROM` (ou `postmaster@<HELO>` pour un expéditeur vide).
    MailFrom,
    /// Identité HELO.
    Helo,
}

/// Résultat d'un contrôle SPF.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SpfOutput {
    /// Résultat.
    pub result: SpfResult,
    /// Identité contrôlée.
    pub identity: SpfIdentity,
    /// Domaine de l'identité (forme ASCII), `None` si l'identité est illisible ou absente.
    pub domain: Option<String>,
}

/// Limites d'une évaluation (RFC 7208 §4.6.4 ; plan du lot 5, §6).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct SpfLimits {
    /// Termes qui interrogent le DNS (`include`, `a`, `mx`, `ptr`, `exists`, `redirect`).
    pub dns_terms: usize,
    /// Réponses vides (`NXDOMAIN` ou aucun enregistrement) tolérées.
    pub void_lookups: usize,
    /// Noms suivis par `mx` et `ptr` (et par la macro `%{p}`).
    pub names_per_lookup: usize,
    /// Délai total d'une évaluation.
    pub timeout: Duration,
}

impl Default for SpfLimits {
    fn default() -> Self {
        Self {
            dns_terms: 10,
            void_lookups: 2,
            names_per_lookup: 10,
            timeout: Duration::from_secs(20),
        }
    }
}

/// Évaluateur SPF.
pub struct SpfVerifier<'a> {
    resolver: &'a dyn MailResolver,
    limits: SpfLimits,
}

/// Fin anticipée d'une évaluation (`temperror` ou `permerror`).
type Abort = SpfResult;

struct State {
    ip: IpAddr,
    local_part: String,
    sender_domain: String,
    helo: String,
    dns_terms: usize,
    void_lookups: usize,
}

type BoxFuture<'b, T> = Pin<Box<dyn Future<Output = T> + Send + 'b>>;

impl<'a> SpfVerifier<'a> {
    /// Évaluateur aux limites de la RFC.
    pub fn new(resolver: &'a dyn MailResolver) -> Self {
        Self::with_limits(resolver, SpfLimits::default())
    }

    /// Évaluateur à limites choisies (essais).
    pub fn with_limits(resolver: &'a dyn MailResolver, limits: SpfLimits) -> Self {
        Self { resolver, limits }
    }

    /// Contrôle de l'identité `MAIL FROM` : `mail_from` est l'adresse de `MAIL FROM` sans
    /// `<>`, vide pour l'expéditeur vide (`postmaster@<helo>` est alors contrôlé).
    pub async fn check_mail_from(&self, ip: IpAddr, helo: &str, mail_from: &str) -> SpfOutput {
        let (local_part, domain) = if mail_from.is_empty() {
            ("postmaster".to_string(), helo_domain(helo))
        } else {
            match mail_from.rsplit_once('@') {
                Some((local, domain)) if !local.is_empty() => {
                    (local.to_string(), to_ascii_domain(domain))
                }
                _ => (String::new(), None),
            }
        };
        self.run(ip, helo, local_part, domain, SpfIdentity::MailFrom)
            .await
    }

    /// Contrôle de l'identité HELO (`postmaster@<helo>`) ; un HELO qui n'est pas un nom de
    /// domaine (adresse entre crochets) donne `none`.
    pub async fn check_helo(&self, ip: IpAddr, helo: &str) -> SpfOutput {
        self.run(
            ip,
            helo,
            "postmaster".to_string(),
            helo_domain(helo),
            SpfIdentity::Helo,
        )
        .await
    }

    async fn run(
        &self,
        ip: IpAddr,
        helo: &str,
        local_part: String,
        domain: Option<String>,
        identity: SpfIdentity,
    ) -> SpfOutput {
        let Some(domain) = domain else {
            return SpfOutput {
                result: SpfResult::None,
                identity,
                domain: None,
            };
        };
        let mut state = State {
            ip: ip.to_canonical(),
            local_part,
            sender_domain: domain.clone(),
            helo: helo_domain(helo).unwrap_or_else(|| helo.to_ascii_lowercase()),
            dns_terms: 0,
            void_lookups: 0,
        };
        let result = match tokio::time::timeout(
            self.limits.timeout,
            self.check_host(&mut state, domain.clone()),
        )
        .await
        {
            Ok(result) => result,
            Err(_) => SpfResult::TempError,
        };
        SpfOutput {
            result,
            identity,
            domain: Some(domain),
        }
    }

    /// `check_host(ip, domain, sender)` (§4).
    fn check_host<'b>(&'b self, state: &'b mut State, domain: String) -> BoxFuture<'b, SpfResult> {
        Box::pin(async move {
            if !is_valid_domain(&domain, true) || !is_multi_label(&domain) {
                return SpfResult::None;
            }
            let record = match self.lookup_record(&domain).await {
                Ok(Some(record)) => record,
                Ok(None) => return SpfResult::None,
                Err(abort) => return abort,
            };
            for directive in &record.directives {
                match self.matches(state, &domain, &directive.mechanism).await {
                    Ok(true) => {
                        return match directive.qualifier {
                            Qualifier::Pass => SpfResult::Pass,
                            Qualifier::Fail => SpfResult::Fail,
                            Qualifier::SoftFail => SpfResult::SoftFail,
                            Qualifier::Neutral => SpfResult::Neutral,
                        }
                    }
                    Ok(false) => {}
                    Err(abort) => return abort,
                }
            }
            match &record.redirect {
                Some(redirect) if !record.has_all() => {
                    if let Err(abort) = self.count_dns_term(state) {
                        return abort;
                    }
                    let target = match self.expand_domain(state, &domain, redirect).await {
                        Ok(target) => target,
                        Err(abort) => return abort,
                    };
                    match self.check_host(state, target).await {
                        SpfResult::None => SpfResult::PermError,
                        result => result,
                    }
                }
                _ => SpfResult::Neutral,
            }
        })
    }

    /// Enregistrement SPF du domaine : `Ok(None)` si aucun (§4.5).
    async fn lookup_record(&self, domain: &str) -> Result<Option<SpfRecord>, Abort> {
        let answer = match self.resolver.txt(domain).await {
            Ok(answer) => answer,
            Err(error) if error.is_temporary() => return Err(SpfResult::TempError),
            Err(_) => return Ok(None),
        };
        let mut records = answer
            .records
            .iter()
            .filter(|txt| record::is_spf_record(txt));
        let Some(first) = records.next() else {
            return Ok(None);
        };
        if records.next().is_some() || first.len() > MAX_POLICY_TXT_BYTES {
            return Err(SpfResult::PermError);
        }
        SpfRecord::parse(first)
            .map(Some)
            .map_err(|_| SpfResult::PermError)
    }

    fn count_dns_term(&self, state: &mut State) -> Result<(), Abort> {
        state.dns_terms += 1;
        if state.dns_terms > self.limits.dns_terms {
            return Err(SpfResult::PermError);
        }
        Ok(())
    }

    fn count_void(&self, state: &mut State) -> Result<(), Abort> {
        state.void_lookups += 1;
        if state.void_lookups > self.limits.void_lookups {
            return Err(SpfResult::PermError);
        }
        Ok(())
    }

    /// Réponse d'une requête d'un mécanisme : absence (réponse vide comptée), panne, nom
    /// invalide.
    fn absent_or_abort(&self, state: &mut State, error: DnsError) -> Result<bool, Abort> {
        match error {
            DnsError::NotFound | DnsError::NoRecords => {
                self.count_void(state)?;
                Ok(false)
            }
            DnsError::InvalidName => Err(SpfResult::PermError),
            DnsError::Temporary | DnsError::Refused => Err(SpfResult::TempError),
        }
    }

    async fn matches(
        &self,
        state: &mut State,
        domain: &str,
        mechanism: &Mechanism,
    ) -> Result<bool, Abort> {
        match mechanism {
            Mechanism::All => Ok(true),
            Mechanism::Ip4 { network, prefix } => {
                Ok(in_network(state.ip, IpAddr::V4(*network), *prefix))
            }
            Mechanism::Ip6 { network, prefix } => {
                Ok(in_network(state.ip, IpAddr::V6(*network), *prefix))
            }
            Mechanism::Include(spec) => {
                self.count_dns_term(state)?;
                let target = self.expand_domain(state, domain, spec).await?;
                match self.check_host(state, target).await {
                    SpfResult::Pass => Ok(true),
                    SpfResult::Fail | SpfResult::SoftFail | SpfResult::Neutral => Ok(false),
                    SpfResult::TempError => Err(SpfResult::TempError),
                    SpfResult::PermError | SpfResult::None => Err(SpfResult::PermError),
                }
            }
            Mechanism::A {
                domain: spec,
                prefix4,
                prefix6,
            } => {
                self.count_dns_term(state)?;
                let target = self.target(state, domain, spec.as_ref()).await?;
                match self.resolver.ips_like(&target, state.ip).await {
                    Ok(answer) => Ok(answer
                        .records
                        .iter()
                        .any(|address| self.in_prefix(state.ip, *address, *prefix4, *prefix6))),
                    Err(error) => self.absent_or_abort(state, error),
                }
            }
            Mechanism::Mx {
                domain: spec,
                prefix4,
                prefix6,
            } => {
                self.count_dns_term(state)?;
                let target = self.target(state, domain, spec.as_ref()).await?;
                let mut exchanges = match self.resolver.mx(&target).await {
                    Ok(answer) => answer.records,
                    Err(error) => return self.absent_or_abort(state, error),
                };
                exchanges.sort_by_key(|record| record.preference);
                for (index, exchange) in exchanges.iter().enumerate() {
                    if index >= self.limits.names_per_lookup {
                        return Err(SpfResult::PermError);
                    }
                    // « MX nul » (RFC 7505) : aucun serveur, aucune correspondance.
                    if exchange.exchange.is_empty() {
                        continue;
                    }
                    match self.resolver.ips_like(&exchange.exchange, state.ip).await {
                        Ok(answer) => {
                            if answer.records.iter().any(|address| {
                                self.in_prefix(state.ip, *address, *prefix4, *prefix6)
                            }) {
                                return Ok(true);
                            }
                        }
                        Err(error) if error.is_temporary() => return Err(SpfResult::TempError),
                        Err(_) => {}
                    }
                }
                Ok(false)
            }
            Mechanism::Ptr(spec) => {
                self.count_dns_term(state)?;
                let target = self.target(state, domain, spec.as_ref()).await?;
                let names = match self.validated_names(state.ip).await {
                    Ok(names) => names,
                    Err(DnsError::NotFound | DnsError::NoRecords) => {
                        self.count_void(state)?;
                        return Ok(false);
                    }
                    // Une erreur DNS de la requête PTR : aucune correspondance (§5.5).
                    Err(_) => return Ok(false),
                };
                Ok(names.iter().any(|name| is_same_or_subdomain(name, &target)))
            }
            Mechanism::Exists(spec) => {
                self.count_dns_term(state)?;
                let target = self.expand_domain(state, domain, spec).await?;
                match self.resolver.ipv4(&target).await {
                    Ok(_) => Ok(true),
                    Err(error) => self.absent_or_abort(state, error),
                }
            }
        }
    }

    fn in_prefix(&self, client: IpAddr, address: IpAddr, prefix4: u8, prefix6: u8) -> bool {
        let prefix = if client.is_ipv4() { prefix4 } else { prefix6 };
        in_network(client, address, prefix)
    }

    async fn target(
        &self,
        state: &mut State,
        domain: &str,
        spec: Option<&MacroString>,
    ) -> Result<String, Abort> {
        match spec {
            Some(spec) => self.expand_domain(state, domain, spec).await,
            None => Ok(domain.to_string()),
        }
    }

    /// Noms inverses de l'adresse confirmés par une requête A ou AAAA (§5.5), dans la limite de
    /// [`SpfLimits::names_per_lookup`] noms lus.
    async fn validated_names(&self, ip: IpAddr) -> Result<Vec<String>, DnsError> {
        let answer = self.resolver.ptr(ip).await?;
        let mut validated = Vec::new();
        for name in answer.records.iter().take(self.limits.names_per_lookup) {
            if let Ok(addresses) = self.resolver.ips_like(name, ip).await {
                if addresses.records.contains(&ip) {
                    validated.push(name.clone());
                }
            }
        }
        Ok(validated)
    }

    /// Développe un `domain-spec` puis le contrôle comme nom de domaine (§4.8, §7.3).
    async fn expand_domain(
        &self,
        state: &mut State,
        domain: &str,
        spec: &MacroString,
    ) -> Result<String, Abort> {
        let expanded = self.expand(state, domain, spec).await?;
        let expanded = expanded.strip_suffix('.').unwrap_or(&expanded);
        let name = truncate_name(expanded).to_ascii_lowercase();
        if !is_valid_domain(&name, true) {
            return Err(SpfResult::PermError);
        }
        Ok(name)
    }

    /// Développe une chaîne à macros (§7.3).
    async fn expand(
        &self,
        state: &mut State,
        domain: &str,
        spec: &MacroString,
    ) -> Result<String, Abort> {
        let mut out = String::new();
        for token in &spec.0 {
            match token {
                MacroToken::Literal(text) => out.push_str(text),
                MacroToken::Macro {
                    letter,
                    url_escape,
                    digits,
                    reverse,
                    delimiters,
                } => {
                    let value = match letter {
                        b's' => format!("{}@{}", state.local_part, state.sender_domain),
                        b'l' => state.local_part.clone(),
                        b'o' => state.sender_domain.clone(),
                        b'd' => domain.to_string(),
                        b'i' => ip_macro(state.ip),
                        b'v' => if state.ip.is_ipv4() { "in-addr" } else { "ip6" }.to_string(),
                        b'h' => state.helo.clone(),
                        b'p' => self.p_macro(state.ip, domain).await,
                        _ => return Err(SpfResult::PermError),
                    };
                    let transformed = transform(&value, *digits, *reverse, delimiters);
                    if *url_escape {
                        out.push_str(&url_escape_text(&transformed));
                    } else {
                        out.push_str(&transformed);
                    }
                }
            }
            if out.len() > 4 * MAX_NAME_BYTES + MAX_POLICY_TXT_BYTES {
                return Err(SpfResult::PermError);
            }
        }
        Ok(out)
    }

    /// Macro `%{p}` : nom inverse confirmé, de préférence `domain` ou l'un de ses sous-domaines
    /// (§7.3) ; `unknown` sinon.
    async fn p_macro(&self, ip: IpAddr, domain: &str) -> String {
        let Ok(names) = self.validated_names(ip).await else {
            return "unknown".to_string();
        };
        names
            .iter()
            .find(|name| name.as_str() == domain)
            .or_else(|| names.iter().find(|name| is_same_or_subdomain(name, domain)))
            .or_else(|| names.first())
            .cloned()
            .unwrap_or_else(|| "unknown".to_string())
    }
}

/// Domaine d'un HELO, `None` pour une adresse entre crochets ou un nom illisible.
fn helo_domain(helo: &str) -> Option<String> {
    if helo.starts_with('[') {
        return None;
    }
    to_ascii_domain(helo)
}

/// Macro `%{i}` : adresse pointée (IPv4) ou quartets pointés (IPv6).
fn ip_macro(ip: IpAddr) -> String {
    match ip {
        IpAddr::V4(v4) => v4.to_string(),
        IpAddr::V6(v6) => {
            let mut parts = Vec::with_capacity(32);
            for byte in v6.octets() {
                parts.push(format!("{:x}", byte >> 4));
                parts.push(format!("{:x}", byte & 0x0f));
            }
            parts.join(".")
        }
    }
}

/// Transformation d'une valeur de macro : découpage sur les délimiteurs (`.` par défaut),
/// renversement, garde des `digits` parties de droite, recollage par `.`.
fn transform(value: &str, digits: Option<u32>, reverse: bool, delimiters: &[u8]) -> String {
    let delimiters: &[u8] = if delimiters.is_empty() {
        b"."
    } else {
        delimiters
    };
    let mut parts: Vec<&str> = value
        .split(|character: char| {
            u8::try_from(character).is_ok_and(|byte| delimiters.contains(&byte))
        })
        .collect();
    if reverse {
        parts.reverse();
    }
    if let Some(digits) = digits {
        let keep = usize::try_from(digits).unwrap_or(usize::MAX);
        if parts.len() > keep {
            parts.drain(..parts.len() - keep);
        }
    }
    parts.join(".")
}

/// Échappement d'une macro en majuscule (RFC 3986 : seuls les caractères non réservés
/// restent).
fn url_escape_text(text: &str) -> String {
    let mut out = String::with_capacity(text.len());
    for byte in text.bytes() {
        if byte.is_ascii_alphanumeric() || b"-._~".contains(&byte) {
            out.push(char::from(byte));
        } else {
            out.push_str(&format!("%{byte:02X}"));
        }
    }
    out
}

/// Nom de plus de 253 octets : étiquettes de gauche retirées une à une (§4.8).
fn truncate_name(name: &str) -> &str {
    let mut current = name;
    while current.len() > MAX_NAME_BYTES {
        match current.split_once('.') {
            Some((_, rest)) => current = rest,
            None => return current,
        }
    }
    current
}

#[cfg(test)]
mod tests;
