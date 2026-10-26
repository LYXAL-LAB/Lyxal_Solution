//! Extraction et normalisation des caractéristiques techniques, normes et performances.

use std::collections::HashMap;

/// Attributs techniques normalisés pour le rapprochement et la qualification.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct CanonicalTechnicalAttributes {
    /// Classe ETIM normalisée (ex: "EC001419")
    pub etim_class: Option<String>,
    /// Norme de référence (ex: "NF EN 520", "NF EN 14195", "NF C 15-100")
    pub standard_norm: Option<String>,
    /// Réaction au feu / Euroclasse (ex: "A1", "A2-s1,d0", "M0", "M1")
    pub fire_rating: Option<String>,
    /// Type de bords pour les plaques (ex: "BA" = amincis, "BD" = droits, "BR" = ronds)
    pub edge_type: Option<String>,
    /// Épaisseur d'acier pour ossatures métalliques (ex: 0.6 mm)
    pub steel_thickness_mm: Option<f64>,
    /// Caractéristiques électriques (courant nominal en A, tension en V, indice IP)
    pub electrical_current_a: Option<f64>,
    pub electrical_ip_rating: Option<String>,
    /// Caractéristiques d'isolation thermique (résistance R en m²·K/W, lambda en W/m·K, matériau)
    pub thermal_resistance_r: Option<f64>,
    pub thermal_lambda: Option<f64>,
    pub insulation_material: Option<String>,
    /// Typologie de plaque de plâtre (STANDARD, HYDROFUGE, COUPE_FEU, PHONIQUE)
    pub board_special_type: Option<String>,
    /// Ensemble des attributs techniques normalisés clé-valeur
    pub normalized_features: HashMap<String, String>,
}

/// Extrait et normalise les caractéristiques techniques à partir des attributs bruts et du libellé
pub fn normalize_technical_attributes(
    raw_attrs: &HashMap<String, String>,
    designation: &str,
) -> CanonicalTechnicalAttributes {
    let mut result = CanonicalTechnicalAttributes::default();
    let text_lower = designation.to_lowercase();

    // 1. Classe ETIM
    if let Some(etim) = find_attr(raw_attrs, &["etim", "etim_class", "classe_etim"]) {
        result.etim_class = Some(etim.trim().to_uppercase());
    }

    // 2. Norme de référence
    if let Some(norm) = find_attr(raw_attrs, &["norme", "standard", "standard_norm", "norm"]) {
        result.standard_norm = Some(norm.trim().to_uppercase());
    } else if text_lower.contains("en 520") || text_lower.contains("en520") {
        result.standard_norm = Some("NF EN 520".to_string());
    } else if text_lower.contains("en 14195") || text_lower.contains("en14195") {
        result.standard_norm = Some("NF EN 14195".to_string());
    } else if text_lower.contains("en 13162") || text_lower.contains("en13162") || text_lower.contains("laine de verre") || text_lower.contains("laine de roche") {
        result.standard_norm = Some("NF EN 13162".to_string());
    } else if text_lower.contains("c 15-100") || text_lower.contains("c15-100") {
        result.standard_norm = Some("NF C 15-100".to_string());
    }

    // 3. Réaction au feu
    if let Some(feu) = find_attr(raw_attrs, &["classement_feu", "fire_rating", "reaction_feu", "feu"]) {
        result.fire_rating = Some(feu.trim().to_uppercase());
    } else if text_lower.contains("a2-s1,d0") || text_lower.contains("a2-s1 d0") {
        result.fire_rating = Some("A2-S1,D0".to_string());
    } else if text_lower.contains("a1") || text_lower.contains("incombustible") {
        result.fire_rating = Some("A1".to_string());
    } else if text_lower.contains("m0") {
        result.fire_rating = Some("M0".to_string());
    } else if text_lower.contains("m1") {
        result.fire_rating = Some("M1".to_string());
    }

    // 4. Type de bords pour plaques
    if let Some(edge) = find_attr(raw_attrs, &["edge_type", "type_bord", "bords", "bord"]) {
        result.edge_type = Some(edge.trim().to_uppercase());
    } else if text_lower.contains("ba13") || text_lower.contains("ks 13") || text_lower.contains("ks13") || text_lower.contains("bords amincis") || text_lower.contains(" ba ") {
        result.edge_type = Some("BA".to_string()); // Bords Amincis
    } else if text_lower.contains("bords droits") || text_lower.contains(" bd ") {
        result.edge_type = Some("BD".to_string());
    } else if text_lower.contains("bords ronds") || text_lower.contains(" br ") {
        result.edge_type = Some("BR".to_string());
    }

    // Typologie de plaque spéciale
    if text_lower.contains("hydro") || text_lower.contains("h1") {
        result.board_special_type = Some("HYDROFUGE".to_string());
    } else if text_lower.contains("flam") || text_lower.contains("coupe-feu") || text_lower.contains("coupe feu") {
        result.board_special_type = Some("COUPE_FEU".to_string());
    } else if text_lower.contains("phonique") || text_lower.contains("acoustique") {
        result.board_special_type = Some("PHONIQUE".to_string());
    } else if text_lower.contains("plaque") || text_lower.contains("ba13") {
        result.board_special_type = Some("STANDARD".to_string());
    }

    // 5. Épaisseur d'acier pour ossatures métalliques
    if text_lower.contains("0,6mm") || text_lower.contains("0.6mm") || text_lower.contains("0,6 mm") || text_lower.contains("0.6 mm") {
        result.steel_thickness_mm = Some(0.6);
    } else if text_lower.contains("rail") || text_lower.contains("montant") {
        result.steel_thickness_mm = Some(0.6);
    }

    // 6. Caractéristiques électriques
    if text_lower.contains("16a") {
        result.electrical_current_a = Some(16.0);
    } else if text_lower.contains("20a") {
        result.electrical_current_a = Some(20.0);
    } else if text_lower.contains("32a") {
        result.electrical_current_a = Some(32.0);
    }

    if text_lower.contains("ip55") {
        result.electrical_ip_rating = Some("IP55".to_string());
    } else if text_lower.contains("ip44") {
        result.electrical_ip_rating = Some("IP44".to_string());
    } else if text_lower.contains("ip20") || text_lower.contains("encastre") || text_lower.contains("encastré") {
        result.electrical_ip_rating = Some("IP20".to_string());
    }

    // 7. Isolation thermique & acoustique (Nouvelle famille Phase 3)
    // Conductivité thermique (lambda)
    if let Some(l_str) = find_attr(raw_attrs, &["lambda", "conductivite", "conductivite_thermique"]) {
        result.thermal_lambda = l_str.replace(',', ".").parse::<f64>().ok();
    } else if text_lower.contains("gr32") || text_lower.contains("0.032") || text_lower.contains("0,032") {
        result.thermal_lambda = Some(0.032);
    } else if text_lower.contains("0.035") || text_lower.contains("0,035") {
        result.thermal_lambda = Some(0.035);
    } else if text_lower.contains("0.038") || text_lower.contains("0,038") {
        result.thermal_lambda = Some(0.038);
    } else if text_lower.contains("ibr") || text_lower.contains("0.040") || text_lower.contains("0,040") {
        result.thermal_lambda = Some(0.040);
    }

    // Résistance thermique (R)
    if let Some(r_str) = find_attr(raw_attrs, &["resistance_thermique", "r_thermique", "r"]) {
        result.thermal_resistance_r = r_str.replace(',', ".").parse::<f64>().ok();
    } else {
        // Recherche motif r=3.15 ou r 3,15 dans le libellé
        for part in text_lower.split_whitespace() {
            if part.starts_with("r=") || part.starts_with("r:") {
                let num = &part[2..];
                if let Ok(v) = num.replace(',', ".").parse::<f64>() {
                    result.thermal_resistance_r = Some(v);
                    break;
                }
            }
        }
    }

    // Matériau isolant
    if text_lower.contains("laine de verre") || text_lower.contains("isover") || text_lower.contains("ursa") {
        result.insulation_material = Some("LAINE_DE_VERRE".to_string());
    } else if text_lower.contains("laine de roche") || text_lower.contains("rockwool") {
        result.insulation_material = Some("LAINE_DE_ROCHE".to_string());
    } else if text_lower.contains("polyuréthane") || text_lower.contains("polyurethane") || text_lower.contains("pur") || text_lower.contains("pir") {
        result.insulation_material = Some("POLYURETHANE".to_string());
    } else if text_lower.contains("polystyrène") || text_lower.contains("polystyrene") || text_lower.contains("pse") {
        result.insulation_material = Some("POLYSTYRENE".to_string());
    }

    // Remplissage map normalisée
    if let Some(ref e) = result.etim_class {
        result.normalized_features.insert("etim_class".to_string(), e.clone());
    }
    if let Some(ref n) = result.standard_norm {
        result.normalized_features.insert("standard_norm".to_string(), n.clone());
    }
    if let Some(ref f) = result.fire_rating {
        result.normalized_features.insert("fire_rating".to_string(), f.clone());
    }
    if let Some(ref b) = result.edge_type {
        result.normalized_features.insert("edge_type".to_string(), b.clone());
    }
    if let Some(ref bt) = result.board_special_type {
        result.normalized_features.insert("board_special_type".to_string(), bt.clone());
    }
    if let Some(st) = result.steel_thickness_mm {
        result.normalized_features.insert("steel_thickness_mm".to_string(), st.to_string());
    }
    if let Some(a) = result.electrical_current_a {
        result.normalized_features.insert("electrical_current_a".to_string(), a.to_string());
    }
    if let Some(ref ip) = result.electrical_ip_rating {
        result.normalized_features.insert("electrical_ip_rating".to_string(), ip.clone());
    }
    if let Some(l) = result.thermal_lambda {
        result.normalized_features.insert("thermal_lambda".to_string(), l.to_string());
    }
    if let Some(r) = result.thermal_resistance_r {
        result.normalized_features.insert("thermal_resistance_r".to_string(), r.to_string());
    }
    if let Some(ref m) = result.insulation_material {
        result.normalized_features.insert("insulation_material".to_string(), m.clone());
    }

    result
}

fn find_attr<'a>(raw_attrs: &'a HashMap<String, String>, candidates: &[&str]) -> Option<&'a String> {
    for &cand in candidates {
        if let Some(val) = raw_attrs.get(cand) {
            return Some(val);
        }
        let norm_cand = cand.to_lowercase().replace([' ', '-', '_', '.'], "");
        for (k, v) in raw_attrs {
            let norm_k = k.to_lowercase().replace([' ', '-', '_', '.'], "");
            if norm_k == norm_cand {
                return Some(v);
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_technical_attributes_extraction() {
        let attrs = HashMap::new();
        let des = "Plaque de plâtre Placoplatre BA13 2500x1200 NF EN 520 A2-s1,d0";
        let res = normalize_technical_attributes(&attrs, des);

        assert_eq!(res.standard_norm, Some("NF EN 520".to_string()));
        assert_eq!(res.fire_rating, Some("A2-S1,D0".to_string()));
        assert_eq!(res.edge_type, Some("BA".to_string()));
    }

    #[test]
    fn test_electrical_extraction() {
        let attrs = HashMap::new();
        let des = "Prise 2P+T 16A encastré blanc Legrand Mosaic";
        let res = normalize_technical_attributes(&attrs, des);

        assert_eq!(res.electrical_current_a, Some(16.0));
        assert_eq!(res.electrical_ip_rating, Some("IP20".to_string()));
    }
}
