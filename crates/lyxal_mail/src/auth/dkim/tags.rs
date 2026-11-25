// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture des balises DKIM (RFC 6376 §3.2, §3.5, §3.6.1), écrite depuis la RFC.

use super::{canonicalization, signing_domain};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::{DkimAlgorithm, DkimCanonicalization, DkimKeyType};

/// Nombre maximal de balises d'une liste.
const MAX_TAGS: usize = 64;
/// Nombre maximal de noms dans `h=`.
const MAX_SIGNED_HEADERS: usize = 512;

/// Liste de balises `nom=valeur` (valeurs sans les espaces qui les entourent).
pub(crate) fn parse_tag_list(text: &str) -> Option<Vec<(String, String)>> {
    let parts: Vec<&str> = text.split(';').collect();
    let mut tags: Vec<(String, String)> = Vec::new();
    let last = parts.len().saturating_sub(1);
    for (position, part) in parts.iter().enumerate() {
        let trimmed = part.trim_matches(is_fws);
        if trimmed.is_empty() {
            if position == last {
                break;
            }
            return None;
        }
        let (name, value) = trimmed.split_once('=')?;
        let name = name.trim_matches(is_fws);
        let mut bytes = name.bytes();
        if !bytes.next().is_some_and(|byte| byte.is_ascii_alphabetic())
            || !bytes.all(|byte| byte.is_ascii_alphanumeric() || byte == b'_')
        {
            return None;
        }
        if tags.iter().any(|(existing, _)| existing == name) || tags.len() >= MAX_TAGS {
            return None;
        }
        tags.push((name.to_string(), value.trim_matches(is_fws).to_string()));
    }
    Some(tags)
}

fn is_fws(character: char) -> bool {
    matches!(character, ' ' | '\t' | '\r' | '\n')
}

fn tag<'t>(tags: &'t [(String, String)], name: &str) -> Option<&'t str> {
    tags.iter()
        .find(|(tag_name, _)| tag_name == name)
        .map(|(_, value)| value.as_str())
}

/// Valeur Base64 dont les espaces de repliement sont retirés.
fn decode_base64(value: &str) -> Option<(Vec<u8>, String)> {
    let compact: String = value
        .chars()
        .filter(|character| !is_fws(*character))
        .collect();
    let bytes = STANDARD.decode(compact.as_bytes()).ok()?;
    Some((bytes, compact))
}

/// Liste `a:b:c` (espaces retirés), éléments non vides.
fn colon_list(value: &str) -> Vec<String> {
    value
        .split(':')
        .map(|item| item.trim_matches(is_fws).to_string())
        .filter(|item| !item.is_empty())
        .collect()
}

fn number(value: &str) -> Option<u64> {
    if value.is_empty() || value.len() > 20 || !value.bytes().all(|byte| byte.is_ascii_digit()) {
        return None;
    }
    value.parse().ok()
}

/// Sélecteur : étiquettes de lettres, chiffres, `-` et `_`.
fn valid_selector(selector: &str) -> bool {
    selector.len() <= 200
        && selector.split('.').all(|label| {
            !label.is_empty()
                && label.len() <= 63
                && label
                    .bytes()
                    .all(|byte| byte.is_ascii_alphanumeric() || byte == b'-' || byte == b'_')
        })
}

/// Signature lue.
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct Signature {
    pub(crate) algorithm: DkimAlgorithm,
    pub(crate) header_canonicalization: DkimCanonicalization,
    pub(crate) body_canonicalization: DkimCanonicalization,
    pub(crate) domain: String,
    pub(crate) selector: String,
    pub(crate) signed_headers: Vec<String>,
    pub(crate) body_hash: Vec<u8>,
    pub(crate) signature: Vec<u8>,
    pub(crate) b_text: String,
    pub(crate) identity_domain: Option<String>,
    pub(crate) length: Option<u64>,
    pub(crate) timestamp: Option<u64>,
    pub(crate) expiration: Option<u64>,
}

/// Signature illisible : domaine et sélecteur s'ils ont pu être lus.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub(crate) struct PartialSignature {
    pub(crate) domain: Option<String>,
    pub(crate) selector: Option<String>,
}

impl Signature {
    /// Lit la valeur brute d'un champ `DKIM-Signature` (§3.5).
    pub(crate) fn parse(raw_value: &[u8]) -> Result<Self, PartialSignature> {
        let mut partial = PartialSignature::default();
        let Ok(text) = std::str::from_utf8(raw_value) else {
            return Err(partial);
        };
        let Some(tags) = parse_tag_list(text) else {
            return Err(partial);
        };
        partial.domain = tag(&tags, "d").and_then(signing_domain);
        partial.selector = tag(&tags, "s")
            .filter(|selector| valid_selector(selector))
            .map(str::to_ascii_lowercase);
        let parsed = (|| {
            if tag(&tags, "v")? != "1" {
                return None;
            }
            let algorithm = DkimAlgorithm::from_tag(tag(&tags, "a")?)?;
            let (header_canonicalization, body_canonicalization) = match tag(&tags, "c") {
                None => (DkimCanonicalization::Simple, DkimCanonicalization::Simple),
                Some(value) => match value.split_once('/') {
                    Some((header, body)) => (canonicalization(header)?, canonicalization(body)?),
                    None => (canonicalization(value)?, DkimCanonicalization::Simple),
                },
            };
            if let Some(query) = tag(&tags, "q") {
                if !colon_list(query)
                    .iter()
                    .any(|method| method.eq_ignore_ascii_case("dns/txt"))
                {
                    return None;
                }
            }
            let signed_headers = colon_list(tag(&tags, "h")?);
            if signed_headers.is_empty() || signed_headers.len() > MAX_SIGNED_HEADERS {
                return None;
            }
            let (body_hash, _) = decode_base64(tag(&tags, "bh")?)?;
            let (signature, b_text) = decode_base64(tag(&tags, "b")?)?;
            if signature.is_empty() {
                return None;
            }
            let identity_domain = match tag(&tags, "i") {
                Some(identity) => {
                    let (_, domain) = identity.rsplit_once('@')?;
                    Some(to_ascii(domain)?)
                }
                None => None,
            };
            let length = match tag(&tags, "l") {
                Some(value) => Some(number(value)?),
                None => None,
            };
            let timestamp = match tag(&tags, "t") {
                Some(value) => Some(number(value)?),
                None => None,
            };
            let expiration = match tag(&tags, "x") {
                Some(value) => Some(number(value)?),
                None => None,
            };
            Some(Self {
                algorithm,
                header_canonicalization,
                body_canonicalization,
                domain: partial.domain.clone()?,
                selector: partial.selector.clone()?,
                signed_headers,
                body_hash,
                signature,
                b_text,
                identity_domain,
                length,
                timestamp,
                expiration,
            })
        })();
        parsed.ok_or(partial)
    }
}

fn to_ascii(domain: &str) -> Option<String> {
    signing_domain(domain)
}

/// Enregistrement de clé lu (§3.6.1).
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct KeyRecord {
    pub(crate) key_type: DkimKeyType,
    pub(crate) public_key: Vec<u8>,
    pub(crate) testing: bool,
    pub(crate) strict: bool,
}

/// Enregistrement de clé inexploitable (clé révoquée, type inconnu, service ou empreinte non
/// permis).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) struct InvalidKeyRecord;

impl KeyRecord {
    /// `None` : texte à écarter (pas une liste de balises, ou `v=` autre que `DKIM1`) ;
    /// `Some(Err)` : enregistrement de clé inexploitable.
    pub(crate) fn parse(text: &str) -> Option<Result<Self, InvalidKeyRecord>> {
        let tags = parse_tag_list(text)?;
        if let Some(position) = tags.iter().position(|(name, _)| name == "v") {
            if position != 0 || tags.first().map(|(_, value)| value.as_str()) != Some("DKIM1") {
                return None;
            }
        }
        Some(Self::from_tags(&tags).ok_or(InvalidKeyRecord))
    }

    fn from_tags(tags: &[(String, String)]) -> Option<Self> {
        if let Some(hashes) = tag(tags, "h") {
            if !colon_list(hashes)
                .iter()
                .any(|hash| hash.eq_ignore_ascii_case("sha256"))
            {
                return None;
            }
        }
        let key_type = match tag(tags, "k") {
            None => DkimKeyType::Rsa,
            Some(value) if value.eq_ignore_ascii_case("rsa") => DkimKeyType::Rsa,
            Some(value) if value.eq_ignore_ascii_case("ed25519") => DkimKeyType::Ed25519,
            Some(_) => return None,
        };
        if let Some(services) = tag(tags, "s") {
            if !colon_list(services)
                .iter()
                .any(|service| service == "*" || service.eq_ignore_ascii_case("email"))
            {
                return None;
            }
        }
        let flags = tag(tags, "t").map(colon_list).unwrap_or_default();
        let (public_key, _) = decode_base64(tag(tags, "p")?)?;
        if public_key.is_empty() {
            return None;
        }
        Some(Self {
            key_type,
            public_key,
            testing: flags.iter().any(|flag| flag.eq_ignore_ascii_case("y")),
            strict: flags.iter().any(|flag| flag.eq_ignore_ascii_case("s")),
        })
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn listes_de_balises() {
        assert_eq!(
            parse_tag_list(" a = 1 ;\r\n\tb=x y;").unwrap(),
            vec![
                ("a".to_string(), "1".to_string()),
                ("b".to_string(), "x y".to_string())
            ]
        );
        assert!(parse_tag_list("a=1; a=2").is_none());
        assert!(parse_tag_list("a=1;; b=2").is_none());
        assert!(parse_tag_list("1a=1").is_none());
        assert!(parse_tag_list("sans-egal").is_none());
    }

    #[test]
    fn signature_lue() {
        let value = b" v=1; a=rsa-sha256; c=relaxed; d=Example.COM; s=sel_1;\r\n\th=From : To;\r\n bh=AAAA; b=AA\r\n AA; i=@mail.example.com; l=10; t=5; x=10";
        let signature = Signature::parse(value).unwrap();
        assert_eq!(signature.domain, "example.com");
        assert_eq!(signature.selector, "sel_1");
        assert_eq!(
            signature.header_canonicalization,
            DkimCanonicalization::Relaxed
        );
        assert_eq!(
            signature.body_canonicalization,
            DkimCanonicalization::Simple
        );
        assert_eq!(signature.signed_headers, vec!["From", "To"]);
        assert_eq!(signature.b_text, "AAAA");
        assert_eq!(
            signature.identity_domain.as_deref(),
            Some("mail.example.com")
        );
        assert_eq!(
            (signature.length, signature.timestamp, signature.expiration),
            (Some(10), Some(5), Some(10))
        );
    }

    #[test]
    fn signatures_refusees() {
        let base = "a=rsa-sha256; d=example.com; s=s; h=from; bh=AAAA; b=AAAA";
        assert!(Signature::parse(format!("v=1; {base}").as_bytes()).is_ok());
        for value in [
            base.to_string(),
            format!("v=2; {base}"),
            format!("v=1; {}", base.replace("rsa-sha256", "rsa-sha1")),
            format!("v=1; {}", base.replace("h=from", "h=")),
            format!("v=1; {}", base.replace("b=AAAA", "b=")),
            format!("v=1; {}", base.replace("bh=AAAA", "bh=!!")),
            format!("v=1; {base}; c=bizarre"),
            format!("v=1; {base}; q=http"),
            format!("v=1; {base}; l=dix"),
            format!("v=1; {base}; i=sans-arobase"),
        ] {
            let error = Signature::parse(value.as_bytes()).unwrap_err();
            assert_eq!(error.domain.as_deref(), Some("example.com"), "{value}");
        }
    }

    #[test]
    fn enregistrements_de_cle() {
        let ok = KeyRecord::parse("v=DKIM1; k=ed25519; t=y:s; p=AAAA")
            .unwrap()
            .unwrap();
        assert_eq!(ok.key_type, DkimKeyType::Ed25519);
        assert!(ok.testing && ok.strict);
        assert!(KeyRecord::parse("v=DKIM2; p=AAAA").is_none());
        assert!(KeyRecord::parse("k=rsa; v=DKIM1; p=AAAA").is_none());
        assert!(KeyRecord::parse("pas une clé").is_none());
        for invalid in [
            "p=",
            "k=dsa; p=AAAA",
            "h=sha1; p=AAAA",
            "s=web; p=AAAA",
            "k=rsa",
        ] {
            assert_eq!(
                KeyRecord::parse(invalid),
                Some(Err(InvalidKeyRecord)),
                "{invalid}"
            );
        }
        assert!(KeyRecord::parse("h=sha1:sha256; s=email; p=AAAA")
            .unwrap()
            .is_ok());
    }
}
