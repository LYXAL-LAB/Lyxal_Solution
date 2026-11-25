// SPDX-License-Identifier: AGPL-3.0-only

//! Vérification DKIM (RFC 6376, 8301, 8463), écrite depuis les RFC (voir `SOURCES.md`).
//!
//! Partage des rôles (règle 13 du §11.3, décisions C4, C5) : ce module lit les balises de
//! `DKIM-Signature` et de l'enregistrement de clé, choisit les en-têtes de `h=` (du bas vers le
//! haut, les absents ne contribuent pas), interroge le DNS, applique `t=`, `x=`, `i=` / `d=`, la
//! politique de `l=` et rend les résultats ; `lyxal_crypto::dkim` calcule l'empreinte du corps,
//! les données signées et vérifie la signature.
//!
//! Politique : 5 signatures vérifiées au plus (les suivantes sont ignorées et ne figurent pas
//! dans les résultats) ; `rsa-sha1` refusé (`permerror`) ; `h=` sans `From` : `permerror` ;
//! signature échue (`x=` passé) : `permerror` ; `t=` à plus de 5 minutes dans le futur :
//! `neutral` ; `l=` plus court que le corps : `policy` (contenu ajouté non signé, jamais
//! `pass`) ; clé révoquée (`p=` vide), absente ou illisible : `permerror` ; panne du DNS :
//! `temperror`.

mod tags;

use super::domain::{is_multi_label, is_same_or_subdomain, to_ascii_domain};
use super::headers::{HeaderField, MessageHeaders};
use crate::dns::MailResolver;
use lyxal_crypto::{
    DkimAlgorithm, DkimBodyHasher, DkimCanonicalization, DkimHeaderCanonicalizer, DkimKeyType,
    DkimPublicKey,
};
use std::collections::HashMap;
use std::time::{SystemTime, UNIX_EPOCH};
use tags::{KeyRecord, Signature};

/// Nombre maximal de signatures vérifiées par message.
pub const MAX_VERIFIED_SIGNATURES: usize = 5;
/// Avance tolérée de `t=` sur notre horloge, en secondes.
const MAX_CLOCK_SKEW_SECONDS: u64 = 300;
/// Longueur de l'extrait de `b=` rendu (`header.b`, RFC 6008).
const SIGNATURE_PREFIX_CHARS: usize = 8;

/// Résultat d'une signature DKIM (RFC 8601 §2.7.1).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum DkimResult {
    /// Message non signé.
    None,
    /// Signature vérifiée.
    Pass,
    /// Signature ou empreinte du corps fausse.
    Fail,
    /// Signature non traitée (horodatage dans le futur).
    Neutral,
    /// Signature valide mais refusée par la politique (`l=` plus court que le corps).
    Policy,
    /// Panne du DNS.
    TempError,
    /// Signature ou clé inexploitable.
    PermError,
}

impl DkimResult {
    /// Mot du résultat (RFC 8601).
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Pass => "pass",
            Self::Fail => "fail",
            Self::Neutral => "neutral",
            Self::Policy => "policy",
            Self::TempError => "temperror",
            Self::PermError => "permerror",
        }
    }
}

/// Résultat d'une signature.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DkimOutput {
    /// Résultat.
    pub result: DkimResult,
    /// Domaine signataire (`d=`, forme ASCII), si la signature a pu être lue jusque-là.
    pub domain: Option<String>,
    /// Sélecteur (`s=`), si lu.
    pub selector: Option<String>,
    /// Début de la valeur `b=` (8 caractères), pour distinguer les signatures (`header.b`).
    pub signature_prefix: Option<String>,
    /// Clé publiée en mode d'essai (`t=y`) : la signature ne doit pas compter plus qu'une
    /// absence de signature (RFC 6376 §3.6.1) ; DMARC l'ignore.
    pub testing: bool,
}

impl DkimOutput {
    fn bare(result: DkimResult) -> Self {
        Self {
            result,
            domain: None,
            selector: None,
            signature_prefix: None,
            testing: false,
        }
    }
}

/// Vérificateur DKIM.
pub struct DkimVerifier<'a> {
    resolver: &'a dyn MailResolver,
    now: Option<u64>,
}

impl<'a> DkimVerifier<'a> {
    /// Vérificateur à l'heure du système.
    pub fn new(resolver: &'a dyn MailResolver) -> Self {
        Self {
            resolver,
            now: None,
        }
    }

    /// Vérificateur à une heure fixée (secondes depuis 1970), pour les essais.
    pub fn at(resolver: &'a dyn MailResolver, now: u64) -> Self {
        Self {
            resolver,
            now: Some(now),
        }
    }

    fn now(&self) -> u64 {
        self.now.unwrap_or_else(|| {
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map(|elapsed| elapsed.as_secs())
                .unwrap_or_default()
        })
    }

    /// Vérifie les signatures d'un message brut. En-tête illisible : un seul résultat
    /// `permerror` s'il porte une signature, `none` sinon.
    pub async fn verify(&self, message: &[u8]) -> Vec<DkimOutput> {
        match MessageHeaders::parse(message) {
            Ok(headers) => self.verify_headers(&headers).await,
            Err(_) => vec![DkimOutput::bare(DkimResult::PermError)],
        }
    }

    /// Vérifie les signatures d'un message déjà découpé : un résultat par signature (les
    /// [`MAX_VERIFIED_SIGNATURES`] premières, du haut vers le bas), ou un seul `none`.
    pub async fn verify_headers(&self, headers: &MessageHeaders<'_>) -> Vec<DkimOutput> {
        let signatures: Vec<(usize, &HeaderField<'_>)> = headers
            .fields
            .iter()
            .enumerate()
            .filter(|(_, field)| field.is("DKIM-Signature"))
            .take(MAX_VERIFIED_SIGNATURES)
            .collect();
        if signatures.is_empty() {
            return vec![DkimOutput::bare(DkimResult::None)];
        }
        let index = HeaderIndex::new(headers);
        let mut outputs = Vec::with_capacity(signatures.len());
        for (position, field) in signatures {
            outputs.push(self.verify_one(headers, &index, position, field).await);
        }
        outputs
    }

    async fn verify_one(
        &self,
        headers: &MessageHeaders<'_>,
        index: &HeaderIndex,
        position: usize,
        field: &HeaderField<'_>,
    ) -> DkimOutput {
        let signature = match Signature::parse(field.value) {
            Ok(signature) => signature,
            Err(partial) => {
                return DkimOutput {
                    domain: partial.domain,
                    selector: partial.selector,
                    ..DkimOutput::bare(DkimResult::PermError)
                }
            }
        };
        let mut output = DkimOutput {
            result: DkimResult::PermError,
            domain: Some(signature.domain.clone()),
            selector: Some(signature.selector.clone()),
            signature_prefix: Some(
                signature
                    .b_text
                    .chars()
                    .take(SIGNATURE_PREFIX_CHARS)
                    .collect(),
            ),
            testing: false,
        };
        output.result = self
            .evaluate(
                headers,
                index,
                position,
                field,
                &signature,
                &mut output.testing,
            )
            .await;
        output
    }

    async fn evaluate(
        &self,
        headers: &MessageHeaders<'_>,
        index: &HeaderIndex,
        position: usize,
        field: &HeaderField<'_>,
        signature: &Signature,
        testing: &mut bool,
    ) -> DkimResult {
        // Contrôles de la signature (RFC 6376 §6.1.1).
        if !signature
            .signed_headers
            .iter()
            .any(|name| name.eq_ignore_ascii_case("from"))
            || !is_multi_label(&signature.domain)
        {
            return DkimResult::PermError;
        }
        if let Some(identity_domain) = &signature.identity_domain {
            if !is_same_or_subdomain(identity_domain, &signature.domain) {
                return DkimResult::PermError;
            }
        }
        let now = self.now();
        if let (Some(timestamp), Some(expiration)) = (signature.timestamp, signature.expiration) {
            if expiration < timestamp {
                return DkimResult::PermError;
            }
        }
        if signature
            .expiration
            .is_some_and(|expiration| expiration < now)
        {
            return DkimResult::PermError;
        }
        if signature
            .timestamp
            .is_some_and(|timestamp| timestamp > now.saturating_add(MAX_CLOCK_SKEW_SECONDS))
        {
            return DkimResult::Neutral;
        }

        // Clé (§6.1.2).
        let key = match self.lookup_key(signature).await {
            Ok(key) => key,
            Err(result) => return result,
        };
        *testing = key.testing;
        if key.strict
            && signature
                .identity_domain
                .as_ref()
                .is_some_and(|identity| identity != &signature.domain)
        {
            return DkimResult::PermError;
        }
        let expected_type = match signature.algorithm {
            DkimAlgorithm::RsaSha256 => DkimKeyType::Rsa,
            DkimAlgorithm::Ed25519Sha256 => DkimKeyType::Ed25519,
        };
        if key.key_type != expected_type {
            return DkimResult::PermError;
        }
        let Ok(public_key) = DkimPublicKey::from_record(key.key_type, &key.public_key) else {
            return DkimResult::PermError;
        };

        // Corps (§6.1.3).
        let mut hasher = DkimBodyHasher::new(signature.body_canonicalization, signature.length);
        hasher.update(headers.body);
        let body = hasher.finish();
        if signature
            .length
            .is_some_and(|length| length > body.canonical_length)
        {
            return DkimResult::PermError;
        }
        if body.digest.as_slice() != signature.body_hash.as_slice() {
            return DkimResult::Fail;
        }

        // En-têtes et signature.
        let mut canonicalizer = DkimHeaderCanonicalizer::new(signature.header_canonicalization);
        let mut used: HashMap<String, usize> = HashMap::new();
        for name in &signature.signed_headers {
            let lower = name.to_ascii_lowercase();
            let count = used.entry(lower.clone()).or_insert(0);
            if let Some(selected) = index.nth_from_bottom(&lower, *count, Some(position)) {
                *count += 1;
                if let Some(selected) = headers.fields.get(selected) {
                    if canonicalizer
                        .push_header(selected.name, selected.value)
                        .is_err()
                    {
                        return DkimResult::PermError;
                    }
                }
            }
        }
        let Ok(signed) = canonicalizer.finish(field.name, field.value) else {
            return DkimResult::PermError;
        };
        match public_key.verify(signature.algorithm, &signed, &signature.signature) {
            Ok(true) => {
                if signature
                    .length
                    .is_some_and(|length| length < body.canonical_length)
                {
                    DkimResult::Policy
                } else {
                    DkimResult::Pass
                }
            }
            Ok(false) => DkimResult::Fail,
            Err(_) => DkimResult::PermError,
        }
    }

    /// Enregistrement de clé `<s>._domainkey.<d>` : un seul enregistrement lisible attendu.
    async fn lookup_key(&self, signature: &Signature) -> Result<KeyRecord, DkimResult> {
        let name = format!("{}._domainkey.{}", signature.selector, signature.domain);
        let answer = match self.resolver.txt(&name).await {
            Ok(answer) => answer,
            Err(error) if error.is_temporary() => return Err(DkimResult::TempError),
            Err(_) => return Err(DkimResult::PermError),
        };
        let mut records = answer
            .records
            .iter()
            .filter_map(|txt| KeyRecord::parse(txt));
        match (records.next(), records.next()) {
            (Some(Ok(record)), None) => Ok(record),
            _ => Err(DkimResult::PermError),
        }
    }
}

/// Positions des champs par nom (minuscules), du bas vers le haut.
struct HeaderIndex {
    positions: HashMap<String, Vec<usize>>,
}

impl HeaderIndex {
    fn new(headers: &MessageHeaders<'_>) -> Self {
        let mut positions: HashMap<String, Vec<usize>> = HashMap::new();
        for (position, field) in headers.fields.iter().enumerate().rev() {
            positions
                .entry(String::from_utf8_lossy(field.trimmed_name()).to_ascii_lowercase())
                .or_default()
                .push(position);
        }
        Self { positions }
    }

    /// `n`-ième champ de ce nom en partant du bas (0 : le dernier), sans compter le champ
    /// `excluded` : la signature en cours de vérification n'est jamais l'un de ses propres
    /// en-têtes signés (RFC 6376 §3.5).
    fn nth_from_bottom(&self, name: &str, n: usize, excluded: Option<usize>) -> Option<usize> {
        self.positions
            .get(name)?
            .iter()
            .copied()
            .filter(|position| Some(*position) != excluded)
            .nth(n)
    }
}

/// Domaine signataire lisible depuis `d=` (forme ASCII).
fn signing_domain(value: &str) -> Option<String> {
    to_ascii_domain(value)
}

/// Canonicalisation d'un mot de `c=`.
fn canonicalization(word: &str) -> Option<DkimCanonicalization> {
    if word.eq_ignore_ascii_case("simple") {
        Some(DkimCanonicalization::Simple)
    } else if word.eq_ignore_ascii_case("relaxed") {
        Some(DkimCanonicalization::Relaxed)
    } else {
        None
    }
}

#[cfg(test)]
mod tests;
