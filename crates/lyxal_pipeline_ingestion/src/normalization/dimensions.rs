//! Normalisation des grandeurs dimensionnelles (en mm) et pondérales (en kg) vers le système SI.

use serde::{Deserialize, Serialize};
use crate::adapters::{RawDimensionsDto, RawWeightDto};

/// Dimensions normalisées selon le standard industriel (longueur, largeur, hauteur en millimètres).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Default)]
pub struct CanonicalDimensions {
    pub length_mm: Option<f64>,
    pub width_mm: Option<f64>,
    pub height_mm: Option<f64>,
}

/// Poids normalisé selon le standard industriel (en kilogrammes).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Default)]
pub struct CanonicalWeight {
    pub net_weight_kg: Option<f64>,
    pub gross_weight_kg: Option<f64>,
}

/// Convertit une valeur dimensionnelle vers le millimètre (mm).
pub fn to_millimeter(value: f64, unit: &str) -> f64 {
    let u = unit.trim().to_lowercase();
    match u.as_str() {
        "m" | "metre" | "mètre" | "mtr" => value * 1000.0,
        "cm" | "centimetre" | "centimètre" => value * 10.0,
        "mm" | "millimetre" | "millimètre" => value,
        _ => value, // Par défaut en BTP, les cotes non spécifiées sont souvent en mm
    }
}

/// Convertit une valeur de masse vers le kilogramme (kg).
pub fn to_kilogram(value: f64, unit: &str) -> f64 {
    let u = unit.trim().to_lowercase();
    match u.as_str() {
        "g" | "gr" | "gramme" => value / 1000.0,
        "kg" | "kilo" | "kilogramme" | "kgm" => value,
        "t" | "tonne" | "tne" => value * 1000.0,
        _ => value,
    }
}

/// Normalise les dimensions brutes
pub fn normalize_dimensions(raw: Option<&RawDimensionsDto>) -> Option<CanonicalDimensions> {
    let r = raw?;
    let unit = r.unit.as_deref().unwrap_or("mm");

    let length_mm = r.length.map(|v| to_millimeter(v, unit));
    let width_mm = r.width.map(|v| to_millimeter(v, unit));
    let height_mm = r.height.map(|v| to_millimeter(v, unit));

    if length_mm.is_some() || width_mm.is_some() || height_mm.is_some() {
        Some(CanonicalDimensions {
            length_mm,
            width_mm,
            height_mm,
        })
    } else {
        None
    }
}

/// Normalise les poids bruts
pub fn normalize_weight(raw: Option<&RawWeightDto>) -> Option<CanonicalWeight> {
    let r = raw?;
    let unit = r.unit.as_deref().unwrap_or("kg");

    let net_weight_kg = r.net_weight.map(|v| to_kilogram(v, unit));
    let gross_weight_kg = r.gross_weight.map(|v| to_kilogram(v, unit));

    if net_weight_kg.is_some() || gross_weight_kg.is_some() {
        Some(CanonicalWeight {
            net_weight_kg,
            gross_weight_kg,
        })
    } else {
        None
    }
}

/// Tente d'extraire des dimensions et du poids depuis une désignation commerciale textuelle
pub fn extract_specs_from_text(text: &str) -> (Option<CanonicalDimensions>, Option<CanonicalWeight>) {
    let lower = text.to_lowercase();
    let mut dims = CanonicalDimensions::default();
    let mut weight = CanonicalWeight::default();

    // Détection motif "2500x1200" ou "2500 x 1200" ou "2500x1200x12,5"
    let parts: Vec<&str> = lower.split_whitespace().collect();
    for part in parts {
        if part.contains('x') {
            let sub: Vec<&str> = part.split('x').collect();
            if sub.len() >= 2 {
                if let (Ok(l), Ok(w)) = (sub[0].replace(',', ".").parse::<f64>(), sub[1].replace(',', ".").parse::<f64>()) {
                    dims.length_mm = Some(l);
                    dims.width_mm = Some(w);
                    if sub.len() >= 3 {
                        if let Ok(h) = sub[2].replace(',', ".").parse::<f64>() {
                            dims.height_mm = Some(h);
                        }
                    }
                }
            }
        }

        // Détection "3m" ou "3,00m"
        if part.ends_with('m') && !part.ends_with("mm") && !part.ends_with("cm") {
            let num_part = &part[..part.len() - 1];
            if let Ok(m) = num_part.replace(',', ".").parse::<f64>() {
                if m > 0.0 && m < 15.0 {
                    dims.length_mm = Some(m * 1000.0);
                }
            }
        }

        // Détection "25kg"
        if part.ends_with("kg") {
            let num_part = &part[..part.len() - 2];
            if let Ok(kg) = num_part.replace(',', ".").parse::<f64>() {
                weight.net_weight_kg = Some(kg);
            }
        }
    }

    // Détection BA13 spécifique (épaisseur nominale 12.5 mm)
    if lower.contains("ba13") && dims.height_mm.is_none() {
        dims.height_mm = Some(12.5);
    }
    // Détection BA15 (15 mm), BA18 (18 mm), BA25 (25 mm)
    if lower.contains("ba15") && dims.height_mm.is_none() {
        dims.height_mm = Some(15.0);
    }
    if lower.contains("ba18") && dims.height_mm.is_none() {
        dims.height_mm = Some(18.0);
    }
    if lower.contains("ba25") && dims.height_mm.is_none() {
        dims.height_mm = Some(25.0);
    }

    // Détection R48 / M48 (largeur nominale 48 mm)
    if (lower.contains("r48") || lower.contains("m48")) && dims.width_mm.is_none() {
        dims.width_mm = Some(48.0);
    }
    // Détection R70 / M70 (largeur nominale 70 mm)
    if (lower.contains("r70") || lower.contains("m70")) && dims.width_mm.is_none() {
        dims.width_mm = Some(70.0);
    }
    // Détection R90 / M90 (largeur nominale 90 mm)
    if (lower.contains("r90") || lower.contains("m90")) && dims.width_mm.is_none() {
        dims.width_mm = Some(90.0);
    }

    let final_dims = if dims.length_mm.is_some() || dims.width_mm.is_some() || dims.height_mm.is_some() {
        Some(dims)
    } else {
        None
    };

    let final_weight = if weight.net_weight_kg.is_some() {
        Some(weight)
    } else {
        None
    };

    (final_dims, final_weight)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unit_conversions() {
        assert_eq!(to_millimeter(2.5, "m"), 2500.0);
        assert_eq!(to_millimeter(120.0, "cm"), 1200.0);
        assert_eq!(to_millimeter(12.5, "mm"), 12.5);

        assert_eq!(to_kilogram(25000.0, "g"), 25.0);
        assert_eq!(to_kilogram(1.2, "t"), 1200.0);
    }

    #[test]
    fn test_extract_specs_from_text() {
        let text = "Plaque BA13 2500x1200 Placoplatre";
        let (dims, _) = extract_specs_from_text(text);
        let d = dims.unwrap();
        assert_eq!(d.length_mm, Some(2500.0));
        assert_eq!(d.width_mm, Some(1200.0));
        assert_eq!(d.height_mm, Some(12.5));

        let rail_text = "Rail Stil Prim R48 3m";
        let (rail_dims, _) = extract_specs_from_text(rail_text);
        let rd = rail_dims.unwrap();
        assert_eq!(rd.length_mm, Some(3000.0));
        assert_eq!(rd.width_mm, Some(48.0));
    }
}
