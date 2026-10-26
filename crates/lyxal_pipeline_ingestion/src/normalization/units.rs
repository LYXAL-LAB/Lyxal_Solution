//! Rapprochement et normalisation des unités de mesure vers le référentiel officiel `base_unite`.

use std::collections::HashMap;
use std::sync::OnceLock;

/// Référentiel des codes canoniques officiels Lyxal OS (`base_unite`).
pub const CANONICAL_UNITS: &[&str] = &[
    "PCE",  // Pièce
    "U",    // Unité
    "M",    // Mètre
    "ML",   // Mètre linéaire
    "CM",   // Centimètre
    "KM",   // Kilomètre
    "M2",   // Mètre carré
    "M3",   // Mètre cube
    "KG",   // Kilogramme
    "T",    // Tonne
    "G",    // Gramme
    "LTR",  // Litre
    "ROUL", // Rouleau
    "BTE",  // Boîte
    "SAC",  // Sac
    "ENS",  // Ensemble
    "PAL",  // Palette
    "CART", // Carton
    "M3H",  // Mètre cube par heure
    "KWH",  // Kilowatt-heure
    "W",    // Watt
    "BAR",  // Bar
];

/// Table de correspondance des alias commerciaux et internationaux (UN/CEFACT) vers `base_unite`.
fn get_units_mapping() -> &'static HashMap<&'static str, &'static str> {
    static MAPPING: OnceLock<HashMap<&'static str, &'static str>> = OnceLock::new();
    MAPPING.get_or_init(|| {
        let mut m = HashMap::new();
        // Pièce / Unité (C62, EA, H87, etc.)
        m.insert("PCE", "PCE");
        m.insert("PC", "PCE");
        m.insert("PIECE", "PCE");
        m.insert("PIÈCE", "PCE");
        m.insert("PIECES", "PCE");
        m.insert("PIÈCES", "PCE");
        m.insert("U", "PCE");
        m.insert("UNITE", "PCE");
        m.insert("UNITÉ", "PCE");
        m.insert("UN", "PCE");
        m.insert("UNIT", "PCE");
        m.insert("EA", "PCE");
        m.insert("EACH", "PCE");
        m.insert("C62", "PCE"); // UN/CEFACT piece
        m.insert("H87", "PCE"); // UN/CEFACT piece

        // Longueur
        m.insert("M", "M");
        m.insert("METRE", "M");
        m.insert("MÈTRE", "M");
        m.insert("MTR", "M"); // UN/CEFACT
        m.insert("ML", "ML");
        m.insert("LM", "ML");
        m.insert("METRE LINEAIRE", "ML");
        m.insert("MÈTRE LINÉAIRE", "ML");
        m.insert("METRE_LINEAIRE", "ML");
        m.insert("CM", "CM");
        m.insert("CENTIMETRE", "CM");
        m.insert("CENTIMÈTRE", "CM");
        m.insert("MM", "MM");
        m.insert("MILLIMETRE", "MM");
        m.insert("MILLIMÈTRE", "MM");
        m.insert("KM", "KM");

        // Surface
        m.insert("M2", "M2");
        m.insert("M²", "M2");
        m.insert("MQ", "M2");
        m.insert("MTK", "M2"); // UN/CEFACT square metre
        m.insert("METRE CARRE", "M2");
        m.insert("MÈTRE CARRÉ", "M2");
        m.insert("METRE_CARRE", "M2");

        // Volume
        m.insert("M3", "M3");
        m.insert("M³", "M3");
        m.insert("MTQ", "M3"); // UN/CEFACT cubic metre
        m.insert("METRE CUBE", "M3");
        m.insert("MÈTRE CUBE", "M3");
        m.insert("L", "LTR");
        m.insert("LT", "LTR");
        m.insert("LTR", "LTR");
        m.insert("LITRE", "LTR");
        m.insert("LITRES", "LTR");

        // Poids
        m.insert("KG", "KG");
        m.insert("KGM", "KG"); // UN/CEFACT
        m.insert("KILO", "KG");
        m.insert("KILOGRAMME", "KG");
        m.insert("T", "T");
        m.insert("TNE", "T"); // UN/CEFACT tonne
        m.insert("TONNE", "T");
        m.insert("G", "G");
        m.insert("GR", "G");
        m.insert("GRAMME", "G");

        // Conditionnements BTP
        m.insert("ROUL", "ROUL");
        m.insert("ROULEAU", "ROUL");
        m.insert("ROLL", "ROUL");
        m.insert("RL", "ROUL");
        m.insert("BTE", "BTE");
        m.insert("BOITE", "BTE");
        m.insert("BOÎTE", "BTE");
        m.insert("BOX", "BTE");
        m.insert("BX", "BTE");
        m.insert("SAC", "SAC");
        m.insert("BAG", "SAC");
        m.insert("SA", "SAC");
        m.insert("ENS", "ENS");
        m.insert("ENSEMBLE", "ENS");
        m.insert("SET", "ENS");
        m.insert("PAL", "PAL");
        m.insert("PALETTE", "PAL");
        m.insert("CART", "CART");
        m.insert("CARTON", "CART");
        m.insert("CT", "CART");

        m
    })
}

/// Normalise une chaîne brute d'unité vers le code canonique officiel de `base_unite`.
pub fn normalize_unit(raw_unit: &str) -> Option<&'static str> {
    let cleaned = raw_unit
        .trim()
        .to_uppercase()
        .replace(['.', '-', '_'], "");

    get_units_mapping().get(cleaned.as_str()).copied()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unit_normalization() {
        assert_eq!(normalize_unit("pce"), Some("PCE"));
        assert_eq!(normalize_unit("C62"), Some("PCE"));
        assert_eq!(normalize_unit("m2"), Some("M2"));
        assert_eq!(normalize_unit("m²"), Some("M2"));
        assert_eq!(normalize_unit("MTR"), Some("M"));
        assert_eq!(normalize_unit("metre lineaire"), Some("ML"));
        assert_eq!(normalize_unit("kg"), Some("KG"));
        assert_eq!(normalize_unit("BOÎTE"), Some("BTE"));
        assert_eq!(normalize_unit("sac"), Some("SAC"));
        assert_eq!(normalize_unit("invalide_xyz"), None);
    }
}
