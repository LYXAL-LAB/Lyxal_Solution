//! Normalisation canonique des fabricants et marques industrielles.

use std::collections::HashMap;
use std::sync::OnceLock;

/// Table des alias de fabricants reconnus dans le BTP.
fn get_manufacturer_alias_map() -> &'static HashMap<&'static str, &'static str> {
    static ALIAS_MAP: OnceLock<HashMap<&'static str, &'static str>> = OnceLock::new();
    ALIAS_MAP.get_or_init(|| {
        let mut m = HashMap::new();
        // Groupe Saint-Gobain : Séparation stricte des entités et métiers (Directive CTO)
        m.insert("SAINT-GOBAIN PLACO", "PLACO");
        m.insert("SAINT GOBAIN PLACO", "PLACO");
        m.insert("PLACOPLATRE", "PLACO");
        m.insert("BPB PLACO", "PLACO");
        m.insert("PLACO", "PLACO");

        m.insert("ISOVER SAINT-GOBAIN", "ISOVER");
        m.insert("SAINT-GOBAIN ISOVER", "ISOVER");
        m.insert("SAINT GOBAIN ISOVER", "ISOVER");
        m.insert("ISOVER", "ISOVER");

        m.insert("SAINT-GOBAIN WEBER", "WEBER");
        m.insert("SAINT GOBAIN WEBER", "WEBER");
        m.insert("WEBER ET BROUTIN", "WEBER");
        m.insert("WEBER", "WEBER");

        m.insert("SAINT-GOBAIN PAM", "PAM");
        m.insert("SAINT GOBAIN PAM", "PAM");
        m.insert("SAINT-GOBAIN PAM PONT-A-MOUSSON", "PAM");
        m.insert("SAINT-GOBAIN PAM PONT-À-MOUSSON", "PAM");
        m.insert("SAINT GOBAIN PAM PONT A MOUSSON", "PAM");
        m.insert("SAINT GOBAIN PAM PONT À MOUSSON", "PAM");
        m.insert("PONT-A-MOUSSON", "PAM");
        m.insert("PONT-À-MOUSSON", "PAM");
        m.insert("PONT A MOUSSON", "PAM");
        m.insert("PONT À MOUSSON", "PAM");
        m.insert("PAM", "PAM");

        m.insert("SAINT-GOBAIN GLASS", "SAINT-GOBAIN GLASS");
        m.insert("SAINT GOBAIN GLASS", "SAINT-GOBAIN GLASS");

        // Cas d'ambiguïté holding groupe non différencié
        m.insert("SAINT-GOBAIN", "SAINT-GOBAIN (INDETERMINE)");
        m.insert("SAINT GOBAIN", "SAINT-GOBAIN (INDETERMINE)");

        // Plâtrerie & Isolants concurrents
        m.insert("KNAUF SAS", "KNAUF");
        m.insert("KNAUF INSULATION", "KNAUF INSULATION"); // Isolation thermique distincte de Knauf plâtre
        m.insert("KNAUF", "KNAUF");

        m.insert("SINIAT FRANCE", "SINIAT");
        m.insert("SINIAT", "SINIAT");
        m.insert("LAFARGE PLATRES", "SINIAT");

        m.insert("SEMIN SAS", "SEMIN");
        m.insert("SEMIN", "SEMIN");

        m.insert("URSA FRANCE", "URSA");
        m.insert("URSA", "URSA");

        m.insert("ROCKWOOL FRANCE", "ROCKWOOL");
        m.insert("ROCKWOOL", "ROCKWOOL");

        // Électricité : Séparation des marques et entités
        m.insert("LEGRAND FRANCE", "LEGRAND");
        m.insert("LEGRAND", "LEGRAND");
        m.insert("BTICINO", "BTICINO");
        m.insert("LEGRAND BTICINO", "BTICINO");

        m.insert("SCHNEIDER ELECTRIC FRANCE", "SCHNEIDER ELECTRIC");
        m.insert("SCHNEIDER ELECTRIC", "SCHNEIDER ELECTRIC");
        m.insert("SCHNEIDER", "SCHNEIDER ELECTRIC");
        m.insert("MERLIN GERIN", "MERLIN GERIN");
        m.insert("TELEMECANIQUE", "TELEMECANIQUE");

        m.insert("HAGER SAS", "HAGER");
        m.insert("HAGER", "HAGER");

        // Étanchéité
        m.insert("SOPREMA SAS", "SOPREMA");
        m.insert("SOPREMA", "SOPREMA");

        m
    })
}

/// Suffixes juridiques et géographiques à nettoyer
const STRIP_SUFFIXES: &[&str] = &[
    " SAS", " SA", " SARL", " EURL", " GMBH", " LTD", " INC", " CORP", " SPA", " SL",
    " FRANCE", " EUROPE", " INTERNATIONAL", " DISTRIBUTION"
];

/// Normalise le nom d'un fabricant ou d'une marque vers sa forme canonique
pub fn normalize_manufacturer(raw_name: &str) -> String {
    let mut cleaned = raw_name
        .trim()
        .to_uppercase()
        .replace(['.', ',', ';'], " ");

    // Remplacement des espaces multiples
    while cleaned.contains("  ") {
        cleaned = cleaned.replace("  ", " ");
    }
    cleaned = cleaned.trim().to_string();

    // Rapprochement alias direct
    if let Some(&canonical) = get_manufacturer_alias_map().get(cleaned.as_str()) {
        return canonical.to_string();
    }

    // Nettoyage des suffixes juridiques
    for &suffix in STRIP_SUFFIXES {
        if cleaned.ends_with(suffix) {
            cleaned = cleaned[..cleaned.len() - suffix.len()].trim().to_string();
        }
    }

    // Deuxième passe sur la table d'alias après nettoyage de suffixe
    if let Some(&canonical) = get_manufacturer_alias_map().get(cleaned.as_str()) {
        canonical.to_string()
    } else {
        cleaned
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_manufacturer_normalization() {
        assert_eq!(normalize_manufacturer("Saint-Gobain Placo SAS"), "PLACO");
        assert_eq!(normalize_manufacturer("Placoplatre"), "PLACO");
        assert_eq!(normalize_manufacturer("Saint-Gobain Isover"), "ISOVER");
        assert_eq!(normalize_manufacturer("Saint-Gobain Weber"), "WEBER");
        assert_eq!(normalize_manufacturer("Saint-Gobain PAM"), "PAM");
        assert_eq!(normalize_manufacturer("Knauf SAS"), "KNAUF");
        assert_eq!(normalize_manufacturer("Knauf Insulation"), "KNAUF INSULATION");
        assert_eq!(normalize_manufacturer("Schneider Electric France"), "SCHNEIDER ELECTRIC");
        assert_eq!(normalize_manufacturer("Legrand France SA"), "LEGRAND");
        assert_eq!(normalize_manufacturer("Legrand Bticino"), "BTICINO");
        assert_eq!(normalize_manufacturer("Fabricant Inconnu SARL"), "FABRICANT INCONNU");

        // Règle CTO : Deux entités d'un même groupe restent strictement distinctes
        assert_ne!(
            normalize_manufacturer("Saint-Gobain Placo"),
            normalize_manufacturer("Saint-Gobain Isover")
        );
    }
}
