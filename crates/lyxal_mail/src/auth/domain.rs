// SPDX-License-Identifier: AGPL-3.0-only

//! Noms de domaine des contrôles d'authenticité : forme ASCII (RFC 8616, décision S16),
//! syntaxe, parenté.

use crate::dns::MAX_NAME_BYTES;

/// Longueur maximale d'une étiquette (RFC 1035 §2.3.4).
pub const MAX_LABEL_BYTES: usize = 63;

/// Vrai si `name` (sans point final, déjà en ASCII) est un nom de domaine lisible : étiquettes
/// de 1 à 63 octets faites de lettres, chiffres, `-` (et `_` si `allow_underscore`, pour les
/// noms de service comme `_dmarc` ou les noms produits par les macros SPF), 253 octets au plus,
/// dernière étiquette non entièrement numérique.
pub fn is_valid_domain(name: &str, allow_underscore: bool) -> bool {
    if name.is_empty() || name.len() > MAX_NAME_BYTES {
        return false;
    }
    let mut last = "";
    for label in name.split('.') {
        if label.is_empty()
            || label.len() > MAX_LABEL_BYTES
            || !label.bytes().all(|byte| {
                byte.is_ascii_alphanumeric() || byte == b'-' || (allow_underscore && byte == b'_')
            })
        {
            return false;
        }
        last = label;
    }
    !last.bytes().all(|byte| byte.is_ascii_digit())
}

/// Vrai si `name` (sans point final) est un nom DNS interrogeable : étiquettes de 1 à 63 octets
/// d'ASCII imprimable, 253 octets au plus. Plus large que [`is_valid_domain`] : un nom produit
/// par une macro SPF n'est pas un nom d'hôte (`user+tag._spf.example.com`, RFC 7208 §4.8).
pub fn is_valid_dns_name(name: &str) -> bool {
    !name.is_empty()
        && name.len() <= MAX_NAME_BYTES
        && name.split('.').all(|label| {
            !label.is_empty()
                && label.len() <= MAX_LABEL_BYTES
                && label.bytes().all(|byte| byte.is_ascii_graphic())
        })
}

/// Vrai si le nom compte au moins deux étiquettes (RFC 7208 §4.3 : « multi-label »).
pub fn is_multi_label(name: &str) -> bool {
    name.contains('.')
}

/// Forme ASCII (A-label, minuscules, sans point final) d'un domaine écrit en ASCII ou en
/// Unicode ; `None` s'il n'est pas un nom de domaine valide.
pub fn to_ascii_domain(domain: &str) -> Option<String> {
    let trimmed = domain.trim().trim_end_matches('.');
    if trimmed.is_empty() {
        return None;
    }
    let ascii = if trimmed.is_ascii() {
        trimmed.to_ascii_lowercase()
    } else {
        idna::domain_to_ascii(trimmed).ok()?
    };
    is_valid_domain(&ascii, false).then_some(ascii)
}

/// Vrai si `child` est `parent` ou l'un de ses sous-domaines (noms en minuscules).
pub fn is_same_or_subdomain(child: &str, parent: &str) -> bool {
    child == parent
        || (child.len() > parent.len()
            && child.ends_with(parent)
            && child.as_bytes().get(child.len() - parent.len() - 1) == Some(&b'.'))
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn syntaxe() {
        assert!(is_valid_domain("example.com", false));
        assert!(is_valid_domain("_dmarc.example.com", true));
        assert!(!is_valid_domain("_dmarc.example.com", false));
        assert!(!is_valid_domain("example..com", false));
        assert!(!is_valid_domain("192.0.2.1", false));
        assert!(!is_valid_domain("exa mple.com", false));
        assert!(!is_valid_domain(&format!("{}.com", "a".repeat(64)), false));
    }

    #[test]
    fn forme_ascii() {
        assert_eq!(to_ascii_domain("Example.COM."), Some("example.com".into()));
        assert_eq!(
            to_ascii_domain("bücher.example"),
            Some("xn--bcher-kva.example".into())
        );
        assert_eq!(to_ascii_domain(""), None);
        assert_eq!(to_ascii_domain("a@b"), None);
    }

    #[test]
    fn parente() {
        assert!(is_same_or_subdomain("a.example.com", "example.com"));
        assert!(is_same_or_subdomain("example.com", "example.com"));
        assert!(!is_same_or_subdomain("badexample.com", "example.com"));
        assert!(!is_same_or_subdomain("com", "example.com"));
    }
}
