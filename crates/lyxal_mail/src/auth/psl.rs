// SPDX-License-Identifier: AGPL-3.0-only

//! Domaine d'organisation (RFC 7489 §3.2, décision S4).
//!
//! [`OrganizationalDomain`] est la question posée par DMARC (et par DKIM pour refuser un `d=`
//! qui serait un suffixe public). Deux réponses :
//!
//! * [`EmbeddedSuffixList`] : la « Public Suffix List » (<https://publicsuffix.org/list/>)
//!   embarquée par la crate `psl`, à version figée (décision S4) ; c'est la liste du serveur ;
//! * [`PublicSuffixList`] : une liste au même format fournie par l'appelant (essais), algorithme
//!   réécrit depuis sa description publique.

use super::domain::to_ascii_domain;
use std::collections::HashSet;

/// Liste des suffixes publics embarquée (crate `psl`, version figée dans `Cargo.toml` : la liste
/// est celle du jour de publication de cette version ; mise à jour par plan, décision P14).
///
/// La crate compare des noms en Unicode : un nom en forme ASCII (A-label) est converti pour la
/// recherche, et le domaine d'organisation est rendu dans la forme reçue (mêmes étiquettes).
/// Règle par défaut `*` : un domaine de premier niveau inconnu de la liste est un suffixe.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct EmbeddedSuffixList;

impl OrganizationalDomain for EmbeddedSuffixList {
    fn organizational_domain(&self, domain: &str) -> Option<String> {
        let labels: Vec<&str> = domain.split('.').collect();
        if labels.iter().any(|label| label.is_empty()) {
            return None;
        }
        let (unicode, converted) = idna::domain_to_unicode(domain);
        converted.ok()?;
        let kept = psl::domain_str(&unicode)?.split('.').count();
        labels
            .len()
            .checked_sub(kept)
            .and_then(|start| labels.get(start..))
            .map(|organizational| organizational.join("."))
    }
}

/// Taille maximale du texte d'une liste, en octets.
pub const MAX_LIST_BYTES: usize = 4 * 1024 * 1024;
/// Nombre maximal de règles d'une liste.
pub const MAX_LIST_RULES: usize = 100_000;

/// Domaine d'organisation d'un nom.
pub trait OrganizationalDomain: Send + Sync {
    /// Domaine d'organisation de `domain` (ASCII, minuscules, sans point final) : le suffixe
    /// public suivi d'une étiquette ; `None` si `domain` est lui-même un suffixe public.
    fn organizational_domain(&self, domain: &str) -> Option<String>;
}

/// Liste illisible.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum PublicSuffixListError {
    /// Texte de plus de [`MAX_LIST_BYTES`] octets ou plus de [`MAX_LIST_RULES`] règles.
    #[error("liste des suffixes publics trop grande")]
    TooLarge,
    /// Règle qui n'est pas un nom de domaine.
    #[error("règle invalide dans la liste des suffixes publics")]
    InvalidRule,
}

/// Liste des suffixes publics : règles simples, jokers (`*.ck`) et exceptions (`!www.ck`).
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct PublicSuffixList {
    rules: HashSet<String>,
    wildcards: HashSet<String>,
    exceptions: HashSet<String>,
}

impl PublicSuffixList {
    /// Lit une liste : une règle par ligne (premier mot), commentaires `//` et lignes vides
    /// ignorés ; règles Unicode converties en forme ASCII.
    pub fn parse(text: &str) -> Result<Self, PublicSuffixListError> {
        if text.len() > MAX_LIST_BYTES {
            return Err(PublicSuffixListError::TooLarge);
        }
        let mut list = Self::default();
        let mut count = 0usize;
        for line in text.lines() {
            let Some(rule) = line.split_whitespace().next() else {
                continue;
            };
            if rule.starts_with("//") {
                continue;
            }
            count += 1;
            if count > MAX_LIST_RULES {
                return Err(PublicSuffixListError::TooLarge);
            }
            let (target, rule) = if let Some(rest) = rule.strip_prefix('!') {
                (&mut list.exceptions, rest)
            } else if let Some(rest) = rule.strip_prefix("*.") {
                (&mut list.wildcards, rest)
            } else {
                (&mut list.rules, rule)
            };
            let ascii = to_ascii_domain(rule).ok_or(PublicSuffixListError::InvalidRule)?;
            target.insert(ascii);
        }
        Ok(list)
    }

    /// Nombre d'étiquettes du suffixe public de `labels` (règle par défaut `*` : 1).
    fn suffix_labels(&self, labels: &[&str]) -> usize {
        let count = labels.len();
        for start in 0..count {
            let candidate = labels.get(start..).unwrap_or_default().join(".");
            if self.exceptions.contains(&candidate) {
                return count - start - 1;
            }
        }
        let mut longest = 1;
        for start in 0..count {
            let candidate = labels.get(start..).unwrap_or_default().join(".");
            if self.rules.contains(&candidate) {
                longest = longest.max(count - start);
            }
            if start >= 1 && self.wildcards.contains(&candidate) {
                longest = longest.max(count - start + 1);
            }
        }
        longest
    }
}

impl OrganizationalDomain for PublicSuffixList {
    fn organizational_domain(&self, domain: &str) -> Option<String> {
        let labels: Vec<&str> = domain.split('.').collect();
        if labels.iter().any(|label| label.is_empty()) {
            return None;
        }
        let suffix = self.suffix_labels(&labels);
        if labels.len() <= suffix {
            return None;
        }
        labels
            .get(labels.len() - suffix - 1..)
            .map(|organizational| organizational.join("."))
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
pub(crate) mod tests {
    use super::*;

    /// Petite liste écrite pour les essais (aucune ligne de la liste publique n'est copiée).
    pub(crate) fn test_list() -> PublicSuffixList {
        PublicSuffixList::parse(
            "// essais\ncom\norg\nnet\nexample\nco.uk\nuk\n*.ck\n!www.ck\nbücher.example\n",
        )
        .unwrap()
    }

    #[test]
    fn domaines_d_organisation() {
        let list = test_list();
        let org = |domain: &str| list.organizational_domain(domain);
        assert_eq!(org("example.com"), Some("example.com".into()));
        assert_eq!(org("a.b.example.com"), Some("example.com".into()));
        assert_eq!(org("com"), None);
        assert_eq!(org("mail.example.co.uk"), Some("example.co.uk".into()));
        assert_eq!(org("co.uk"), None);
        assert_eq!(org("a.b.ck"), Some("a.b.ck".into()));
        assert_eq!(org("b.ck"), None);
        assert_eq!(org("www.ck"), Some("www.ck".into()));
        assert_eq!(org("x.www.ck"), Some("www.ck".into()));
        // Règle par défaut `*` : un domaine de premier niveau inconnu est un suffixe.
        assert_eq!(org("a.b.inconnu"), Some("b.inconnu".into()));
        assert_eq!(
            org("x.y.xn--bcher-kva.example"),
            Some("y.xn--bcher-kva.example".into())
        );
        assert_eq!(org("a..b"), None);
    }

    #[test]
    fn liste_embarquee() {
        let org = |domain: &str| EmbeddedSuffixList.organizational_domain(domain);
        assert_eq!(org("example.com"), Some("example.com".into()));
        assert_eq!(org("a.b.example.com"), Some("example.com".into()));
        assert_eq!(org("com"), None);
        assert_eq!(org("mail.example.co.uk"), Some("example.co.uk".into()));
        assert_eq!(org("co.uk"), None);
        // Joker et exception de la liste publique (`*.ck`, `!www.ck`)
        assert_eq!(org("a.b.ck"), Some("a.b.ck".into()));
        assert_eq!(org("b.ck"), None);
        assert_eq!(org("x.www.ck"), Some("www.ck".into()));
        // Suffixe en Unicode dans la liste (公司.cn), nom reçu en forme ASCII
        assert_eq!(
            org("mail.exemple.xn--55qx5d.cn"),
            Some("exemple.xn--55qx5d.cn".into())
        );
        assert_eq!(org("xn--55qx5d.cn"), None);
        // Étiquette en forme ASCII hors du suffixe : rendue telle qu'elle est reçue
        assert_eq!(
            org("a.xn--bcher-kva.example.org"),
            Some("example.org".into())
        );
        assert_eq!(org("www.xn--bcher-kva.de"), Some("xn--bcher-kva.de".into()));
        // Règle par défaut `*` : domaine de premier niveau inconnu de la liste
        assert_eq!(org("a.b.inconnu-lyxal"), Some("b.inconnu-lyxal".into()));
        assert_eq!(org("inconnu-lyxal"), None);
        assert_eq!(org("a..b"), None);
        assert_eq!(org(""), None);
    }

    #[test]
    fn listes_refusees() {
        assert_eq!(
            PublicSuffixList::parse("a b\n!!x\n"),
            Err(PublicSuffixListError::InvalidRule)
        );
        let large = "a".repeat(MAX_LIST_BYTES + 1);
        assert_eq!(
            PublicSuffixList::parse(&large),
            Err(PublicSuffixListError::TooLarge)
        );
    }
}
