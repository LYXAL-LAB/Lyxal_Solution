//! Lecture de l'en-tête HTTP `Accept-Language` (RFC 9110 §12.5.4).
//!
//! Lecture seule : les étiquettes ne sont pas validées ici, `fn::i18n_locale_resolve` les met sous
//! forme canonique et ignore les invalides.

/// Nombre maximal de candidats retenus (limite de `fn::i18n_locale_resolve`).
pub const MAX_CANDIDATES: usize = 20;

/// Étiquettes de l'en-tête par poids décroissant (ordre d'origine à poids égal), sans `*` ni
/// entrée de poids nul, 20 au plus. Un poids mal formé écarte son entrée.
pub fn candidates(header: &str) -> Vec<String> {
    let mut weighted: Vec<(u16, usize, String)> = header
        .split(',')
        .enumerate()
        .filter_map(|(position, entry)| {
            let mut parts = entry.split(';');
            let tag = parts.next()?.trim();
            if tag.is_empty() || tag == "*" {
                return None;
            }
            let mut weight = 1000;
            for parameter in parts {
                let (name, value) = parameter.split_once('=')?;
                if name.trim().eq_ignore_ascii_case("q") {
                    weight = quality(value.trim())?;
                }
            }
            (weight > 0).then(|| (weight, position, tag.to_string()))
        })
        .collect();
    weighted.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.cmp(&b.1)));
    weighted
        .into_iter()
        .map(|(_, _, tag)| tag)
        .take(MAX_CANDIDATES)
        .collect()
}

/// Poids en millièmes (`qvalue` : `0`, `1`, `0.5`, `0.125`, au plus trois décimales).
fn quality(value: &str) -> Option<u16> {
    let (whole, fraction) = value.split_once('.').unwrap_or((value, ""));
    if fraction.len() > 3 || !fraction.chars().all(|c| c.is_ascii_digit()) {
        return None;
    }
    let digits = format!("{fraction:0<3}");
    let thousandths: u16 = digits.parse().ok()?;
    match whole {
        "0" => Some(thousandths),
        "1" if thousandths == 0 => Some(1000),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sorts_by_weight_and_keeps_order_on_ties() {
        assert_eq!(
            candidates("de;q=0.5, fr-CA, en;q=0.8, es"),
            vec!["fr-CA", "es", "en", "de"]
        );
    }

    #[test]
    fn drops_wildcard_zero_weight_and_malformed_entries() {
        assert_eq!(
            candidates("*, it;q=0, nl;q=abc, pt;q=1.5, ,sv;q=0.25"),
            vec!["sv"]
        );
        assert_eq!(candidates("fr;Q=0.9 , en ; q=0.1"), vec!["fr", "en"]);
        assert!(candidates("").is_empty());
    }

    #[test]
    fn keeps_at_most_twenty_candidates() {
        let header = (0..30)
            .map(|i| format!("l{i}"))
            .collect::<Vec<_>>()
            .join(",");
        assert_eq!(candidates(&header).len(), MAX_CANDIDATES);
    }

    #[test]
    fn parses_quality_values() {
        assert_eq!(quality("1"), Some(1000));
        assert_eq!(quality("1.000"), Some(1000));
        assert_eq!(quality("0.125"), Some(125));
        assert_eq!(quality("0.5"), Some(500));
        assert_eq!(quality("0"), Some(0));
        assert_eq!(quality("0.1234"), None);
        assert_eq!(quality("2"), None);
    }
}
