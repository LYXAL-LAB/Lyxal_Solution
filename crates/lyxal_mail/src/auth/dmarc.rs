// SPDX-License-Identifier: AGPL-3.0-only

//! DMARC (RFC 7489), écrit depuis la RFC (voir `SOURCES.md`) ; cas d'essai transposés de Mox
//! (`dmarc/dmarc_test.go`, MIT).
//!
//! Domaine de chaque adresse de `From` ; enregistrement `_dmarc.<domaine>`, sinon celui du
//! domaine d'organisation ([`OrganizationalDomain`], décision S4) ; alignement souple ou strict
//! de SPF (`MAIL FROM`) et de DKIM (`d=`) ; politique `p`, `sp`, `pct`. Adresses `rua` / `ruf`
//! lues et non utilisées (rapports au lot 7). Décision de réception (S6) :
//! [`DmarcDisposition`].

use super::dkim::{DkimOutput, DkimResult};
use super::domain::to_ascii_domain;
use super::psl::OrganizationalDomain;
use super::spf::{SpfOutput, SpfResult};
use crate::dns::{MailResolver, MAX_NAME_BYTES, MAX_POLICY_TXT_BYTES};
use lyxal_mail_proto::mime::{AddressEntry, Envelope};
use std::time::Duration;

/// Nombre maximal de domaines d'auteur évalués par message ; la session SMTP refuse un message
/// qui en annonce davantage (`550 5.7.1`).
pub const MAX_AUTHOR_DOMAINS: usize = 10;
/// Délai total de l'évaluation DMARC d'un message.
const DMARC_TIMEOUT: Duration = Duration::from_secs(20);

/// Résultat DMARC (RFC 7489 §11.2 ; mots de la RFC 8601).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum DmarcResult {
    /// Aucun enregistrement (ou plusieurs : politique non appliquée).
    None,
    /// Au moins un identifiant authentifié et aligné.
    Pass,
    /// Aucun identifiant authentifié et aligné.
    Fail,
    /// Panne du DNS (enregistrement, ou contrôle SPF / DKIM sans autre réussite).
    TempError,
    /// Enregistrement illisible.
    PermError,
}

impl DmarcResult {
    /// Mot du résultat.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Pass => "pass",
            Self::Fail => "fail",
            Self::TempError => "temperror",
            Self::PermError => "permerror",
        }
    }
}

/// Politique demandée par le domaine (`p=`, `sp=`).
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum DmarcPolicy {
    /// Aucune action.
    None,
    /// Mise à l'écart (dossier « Junk »).
    Quarantine,
    /// Refus.
    Reject,
}

impl DmarcPolicy {
    /// Mot de la politique.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Quarantine => "quarantine",
            Self::Reject => "reject",
        }
    }

    fn parse(value: &str) -> Option<Self> {
        match value.to_ascii_lowercase().as_str() {
            "none" => Some(Self::None),
            "quarantine" => Some(Self::Quarantine),
            "reject" => Some(Self::Reject),
            _ => None,
        }
    }

    /// Politique immédiatement moins sévère (message hors de l'échantillon `pct`, §6.6.4).
    fn weaker(self) -> Self {
        match self {
            Self::Reject => Self::Quarantine,
            Self::Quarantine | Self::None => Self::None,
        }
    }
}

/// Mode d'alignement (`adkim=`, `aspf=`).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Alignment {
    /// `r` : même domaine d'organisation.
    Relaxed,
    /// `s` : domaines identiques.
    Strict,
}

/// Enregistrement DMARC lu.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DmarcRecord {
    /// `p=`.
    pub policy: DmarcPolicy,
    /// `sp=` (sous-domaines), s'il est donné.
    pub subdomain_policy: Option<DmarcPolicy>,
    /// `adkim=` (souple par défaut).
    pub dkim_alignment: Alignment,
    /// `aspf=` (souple par défaut).
    pub spf_alignment: Alignment,
    /// `pct=` (100 par défaut).
    pub percentage: u8,
    /// `rua=` (lu, non utilisé au lot 5).
    pub aggregate_reports: Vec<String>,
    /// `ruf=` (lu, non utilisé au lot 5).
    pub failure_reports: Vec<String>,
}

/// Enregistrement illisible.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) struct DmarcSyntaxError;

/// Vrai si le texte TXT est un enregistrement DMARC (commence par `v=DMARC1`, §6.6.3).
fn is_dmarc_record(text: &str) -> bool {
    let trimmed = text.trim_start();
    trimmed.strip_prefix("v=DMARC1").is_some_and(|rest| {
        rest.is_empty() || rest.starts_with(';') || rest.starts_with([' ', '\t'])
    })
}

impl DmarcRecord {
    /// Lit un enregistrement (§6.3, §6.4). Balises inconnues ignorées ; `p=` absent ou
    /// invalide : `p=none` si `rua=` donne une adresse, sinon erreur (§6.6.3).
    pub(crate) fn parse(text: &str) -> Result<Self, DmarcSyntaxError> {
        let mut tags = Vec::new();
        for (position, part) in text.split(';').enumerate() {
            let part = part.trim_matches([' ', '\t']);
            if part.is_empty() {
                continue;
            }
            let (name, value) = part.split_once('=').ok_or(DmarcSyntaxError)?;
            let name = name.trim_matches([' ', '\t']).to_ascii_lowercase();
            let value = value.trim_matches([' ', '\t']).to_string();
            if position == 0 && (name != "v" || value != "DMARC1") {
                return Err(DmarcSyntaxError);
            }
            if name.is_empty() || !name.bytes().all(|byte| byte.is_ascii_alphanumeric()) {
                return Err(DmarcSyntaxError);
            }
            tags.push((name, value));
        }
        let get = |name: &str| {
            tags.iter()
                .find(|(tag, _)| tag == name)
                .map(|(_, value)| value.as_str())
        };
        let uris = |name: &str| -> Vec<String> {
            get(name)
                .map(|value| {
                    value
                        .split(',')
                        .map(|uri| uri.trim().to_string())
                        .filter(|uri| !uri.is_empty())
                        .collect()
                })
                .unwrap_or_default()
        };
        let aggregate_reports = uris("rua");
        let failure_reports = uris("ruf");
        let alignment = |name: &str| match get(name).map(str::to_ascii_lowercase).as_deref() {
            None | Some("r") => Ok(Alignment::Relaxed),
            Some("s") => Ok(Alignment::Strict),
            Some(_) => Err(DmarcSyntaxError),
        };
        let policy = get("p").and_then(DmarcPolicy::parse);
        let subdomain_policy = get("sp").map(DmarcPolicy::parse);
        let (policy, subdomain_policy) = match (policy, subdomain_policy) {
            (Some(policy), None) => (policy, None),
            (Some(policy), Some(Some(subdomain))) => (policy, Some(subdomain)),
            _ if aggregate_reports.iter().any(|uri| is_report_uri(uri)) => {
                (DmarcPolicy::None, None)
            }
            _ => return Err(DmarcSyntaxError),
        };
        let percentage = match get("pct") {
            None => 100,
            Some(value) => value
                .parse::<u8>()
                .ok()
                .filter(|value| *value <= 100)
                .ok_or(DmarcSyntaxError)?,
        };
        Ok(Self {
            policy,
            subdomain_policy,
            dkim_alignment: alignment("adkim")?,
            spf_alignment: alignment("aspf")?,
            percentage,
            aggregate_reports,
            failure_reports,
        })
    }
}

/// Adresse de rapport lisible (`mailto:` suivi d'une adresse, §6.2).
fn is_report_uri(uri: &str) -> bool {
    uri.get(..7)
        .is_some_and(|scheme| scheme.eq_ignore_ascii_case("mailto:"))
        && uri.get(7..).is_some_and(|address| address.contains('@'))
}

/// Résultat DMARC pour un domaine d'auteur.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DmarcOutput {
    /// Résultat.
    pub result: DmarcResult,
    /// Domaine de l'adresse `From` (`header.from`, forme ASCII).
    pub from_domain: String,
    /// Domaine où l'enregistrement a été trouvé.
    pub record_domain: Option<String>,
    /// Politique applicable (`sp=` pour un sous-domaine couvert par l'enregistrement du domaine
    /// d'organisation, `p=` sinon), si un enregistrement a été lu.
    pub policy: Option<DmarcPolicy>,
    /// `pct=` de l'enregistrement (100 sans enregistrement).
    pub percentage: u8,
    /// SPF réussi et aligné.
    pub spf_aligned: bool,
    /// Une signature DKIM réussie et alignée.
    pub dkim_aligned: bool,
}

/// Décision de réception d'un message selon DMARC (décision S6).
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum DmarcDisposition {
    /// Remise normale.
    Accept,
    /// Remise dans le dossier de rôle `junk`.
    Quarantine,
    /// `451 4.7.5` : panne pendant que `reject` est en jeu, l'expéditeur réessaie.
    TempFail,
    /// `550 5.7.1` : message non remis.
    Reject,
}

impl DmarcOutput {
    /// Décision pour ce domaine. `enforce` : réglage `smtp.dmarc_enforce` (faux : résultat
    /// seulement) ; `roll` : tirage de 0 à 99 pour `pct=` (voir [`sample_roll`]).
    pub fn disposition(&self, enforce: bool, roll: u8) -> DmarcDisposition {
        if !enforce {
            return DmarcDisposition::Accept;
        }
        match (self.result, self.policy) {
            (DmarcResult::Fail, Some(policy)) => {
                let policy = if roll < self.percentage {
                    policy
                } else {
                    policy.weaker()
                };
                match policy {
                    DmarcPolicy::Reject => DmarcDisposition::Reject,
                    DmarcPolicy::Quarantine => DmarcDisposition::Quarantine,
                    DmarcPolicy::None => DmarcDisposition::Accept,
                }
            }
            (DmarcResult::TempError, Some(DmarcPolicy::Reject)) => DmarcDisposition::TempFail,
            _ => DmarcDisposition::Accept,
        }
    }

    /// Décision la plus sévère de plusieurs domaines d'auteur (un seul tirage pour tous).
    pub fn combined_disposition(outputs: &[Self], enforce: bool, roll: u8) -> DmarcDisposition {
        outputs
            .iter()
            .map(|output| output.disposition(enforce, roll))
            .max()
            .unwrap_or(DmarcDisposition::Accept)
    }
}

/// Tirage de 0 à 99 pour `pct=` (aucun usage cryptographique).
pub fn sample_roll() -> u8 {
    fastrand::u8(0..100)
}

/// Domaines d'auteur d'un message (adresses de `From`, membres de groupes compris), en forme
/// ASCII, sans doublon, dans l'ordre ; les adresses illisibles sont ignorées.
pub fn author_domains(envelope: &Envelope) -> Vec<String> {
    let mut domains: Vec<String> = Vec::new();
    let addresses = envelope.from.iter().flat_map(|entry| match entry {
        AddressEntry::Mailbox(address) => std::slice::from_ref(address).iter(),
        AddressEntry::Group { members, .. } => members.iter(),
    });
    for address in addresses {
        let Some(domain) = address
            .address
            .as_deref()
            .and_then(|text| text.rsplit_once('@'))
            .and_then(|(_, domain)| to_ascii_domain(domain))
        else {
            continue;
        };
        if !domains.contains(&domain) {
            domains.push(domain);
        }
    }
    domains
}

/// Évaluateur DMARC.
pub struct DmarcVerifier<'a> {
    resolver: &'a dyn MailResolver,
    organizational: &'a dyn OrganizationalDomain,
}

enum Lookup {
    Found(Box<DmarcRecord>),
    Absent,
    Multiple,
    Invalid,
    Temporary,
}

impl<'a> DmarcVerifier<'a> {
    /// Évaluateur sur un résolveur et une source de domaines d'organisation.
    pub fn new(
        resolver: &'a dyn MailResolver,
        organizational: &'a dyn OrganizationalDomain,
    ) -> Self {
        Self {
            resolver,
            organizational,
        }
    }

    /// Évalue chaque domaine d'auteur (les [`MAX_AUTHOR_DOMAINS`] premiers) avec le résultat
    /// SPF de l'identité `MAIL FROM` et les résultats DKIM. Délai total de 20 s : les domaines
    /// non évalués à temps rendent `temperror` sans politique connue.
    pub async fn verify(
        &self,
        from_domains: &[String],
        spf: &SpfOutput,
        dkim: &[DkimOutput],
    ) -> Vec<DmarcOutput> {
        let domains: Vec<&String> = from_domains.iter().take(MAX_AUTHOR_DOMAINS).collect();
        let mut outputs = Vec::with_capacity(domains.len());
        let deadline = tokio::time::Instant::now() + DMARC_TIMEOUT;
        for domain in domains {
            let evaluation =
                tokio::time::timeout_at(deadline, self.verify_domain(domain, spf, dkim));
            outputs.push(match evaluation.await {
                Ok(output) => output,
                Err(_) => Self::bare(domain, DmarcResult::TempError),
            });
        }
        outputs
    }

    fn bare(domain: &str, result: DmarcResult) -> DmarcOutput {
        DmarcOutput {
            result,
            from_domain: domain.to_string(),
            record_domain: None,
            policy: None,
            percentage: 100,
            spf_aligned: false,
            dkim_aligned: false,
        }
    }

    async fn verify_domain(
        &self,
        from_domain: &str,
        spf: &SpfOutput,
        dkim: &[DkimOutput],
    ) -> DmarcOutput {
        let organizational = self.organizational.organizational_domain(from_domain);
        let (record, record_domain) = match self.lookup(from_domain).await {
            Lookup::Found(record) => (record, from_domain.to_string()),
            Lookup::Absent => match organizational.as_deref() {
                Some(organizational) if organizational != from_domain => {
                    match self.lookup(organizational).await {
                        Lookup::Found(record) => (record, organizational.to_string()),
                        other => return Self::bare(from_domain, Self::lookup_result(&other)),
                    }
                }
                _ => return Self::bare(from_domain, DmarcResult::None),
            },
            other => return Self::bare(from_domain, Self::lookup_result(&other)),
        };
        let policy = if record_domain != from_domain {
            record.subdomain_policy.unwrap_or(record.policy)
        } else {
            record.policy
        };
        let spf_aligned = spf.result == SpfResult::Pass
            && spf
                .domain
                .as_deref()
                .is_some_and(|domain| self.aligned(domain, from_domain, record.spf_alignment));
        let dkim_aligned = dkim.iter().any(|output| {
            output.result == DkimResult::Pass
                && !output.testing
                && output
                    .domain
                    .as_deref()
                    .is_some_and(|domain| self.aligned(domain, from_domain, record.dkim_alignment))
        });
        let result = if spf_aligned || dkim_aligned {
            DmarcResult::Pass
        } else if spf.result == SpfResult::TempError
            || dkim
                .iter()
                .any(|output| output.result == DkimResult::TempError)
        {
            DmarcResult::TempError
        } else {
            DmarcResult::Fail
        };
        DmarcOutput {
            result,
            from_domain: from_domain.to_string(),
            record_domain: Some(record_domain),
            policy: Some(policy),
            percentage: record.percentage,
            spf_aligned,
            dkim_aligned,
        }
    }

    fn lookup_result(lookup: &Lookup) -> DmarcResult {
        match lookup {
            Lookup::Temporary => DmarcResult::TempError,
            Lookup::Invalid => DmarcResult::PermError,
            Lookup::Found(_) | Lookup::Absent | Lookup::Multiple => DmarcResult::None,
        }
    }

    /// Enregistrement de `_dmarc.<domain>` (§6.6.3).
    async fn lookup(&self, domain: &str) -> Lookup {
        let name = format!("_dmarc.{domain}");
        if name.len() > MAX_NAME_BYTES {
            return Lookup::Absent;
        }
        let answer = match self.resolver.txt(&name).await {
            Ok(answer) => answer,
            Err(error) if error.is_temporary() => return Lookup::Temporary,
            Err(_) => return Lookup::Absent,
        };
        let mut records = answer.records.iter().filter(|text| is_dmarc_record(text));
        match (records.next(), records.next()) {
            (None, _) => Lookup::Absent,
            (Some(_), Some(_)) => Lookup::Multiple,
            (Some(text), None) if text.len() > MAX_POLICY_TXT_BYTES => Lookup::Invalid,
            (Some(text), None) => match DmarcRecord::parse(text) {
                Ok(record) => Lookup::Found(Box::new(record)),
                Err(_) => Lookup::Invalid,
            },
        }
    }

    fn aligned(&self, authenticated: &str, from_domain: &str, mode: Alignment) -> bool {
        let authenticated = authenticated.to_ascii_lowercase();
        match mode {
            Alignment::Strict => authenticated == from_domain,
            Alignment::Relaxed => {
                match (
                    self.organizational.organizational_domain(&authenticated),
                    self.organizational.organizational_domain(from_domain),
                ) {
                    (Some(left), Some(right)) => left == right,
                    _ => false,
                }
            }
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests;
