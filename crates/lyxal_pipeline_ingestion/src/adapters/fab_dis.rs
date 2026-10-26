//! Adaptateur FAB-DIS conforme aux standards BTP FAB-DIS 2.3 et FAB-DIS 3.0.
//!
//! Gère :
//! - Le format multi-blocs FAB-DIS 2.3 (Tranches Commerce [C], Logistique [L], Média [M], Réglementaire [R])
//! - Le format tabulaire unifié FAB-DIS 3.0

use async_trait::async_trait;
use serde_json::json;
use std::collections::HashMap;

use super::{RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter};
use crate::error::IngestionError;
use crate::types::SourceFormat;

/// Adaptateur officiel pour les catalogues au format standard FAB-DIS.
#[derive(Debug, Clone, Default)]
pub struct FabDisAdapter;

impl FabDisAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Détermine si le flux est au format multi-blocs (lignes préfixées C, L, M, R) ou tabulaire
    fn is_multi_block(content: &str) -> bool {
        for line in content.lines().take(15) {
            let trimmed = line.trim();
            if trimmed.starts_with("C;")
                || trimmed.starts_with("C\t")
                || trimmed.starts_with("COMMERCE;")
                || trimmed.starts_with("L;")
                || trimmed.starts_with("M;")
                || trimmed.starts_with("R;")
            {
                return true;
            }
        }
        false
    }

    /// Parse le format multi-blocs FAB-DIS 2.3
    fn parse_multi_block(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError> {
        // Regroupement des blocs par référence fabricant
        let mut commerce_records: HashMap<String, (usize, HashMap<String, String>, String)> = HashMap::new();
        let mut logistics_records: HashMap<String, HashMap<String, String>> = HashMap::new();
        let mut reg_records: HashMap<String, HashMap<String, String>> = HashMap::new();

        for (idx, line) in content.lines().enumerate() {
            let trimmed = line.trim();
            if trimmed.is_empty() || trimmed.starts_with('#') {
                continue;
            }

            let delimiter = if trimmed.contains(';') { ';' } else { '\t' };
            let parts: Vec<&str> = trimmed.split(delimiter).map(|s| s.trim()).collect();
            if parts.is_empty() {
                continue;
            }

            let block_type = parts[0].to_uppercase();
            match block_type.as_str() {
                "C" | "COMMERCE" => {
                    // Structure typique C : C;REF_FAB;EAN;DESIGNATION;MARQUE;UNITE;PRIX
                    if parts.len() >= 2 {
                        let ref_fab = parts[1].to_string();
                        let mut map = HashMap::new();
                        map.insert("ref_fab".to_string(), ref_fab.clone());
                        if parts.len() > 2 { map.insert("ean".to_string(), parts[2].to_string()); }
                        if parts.len() > 3 { map.insert("designation".to_string(), parts[3].to_string()); }
                        if parts.len() > 4 { map.insert("marque".to_string(), parts[4].to_string()); }
                        if parts.len() > 5 { map.insert("unite".to_string(), parts[5].to_string()); }
                        if parts.len() > 6 { map.insert("prix".to_string(), parts[6].to_string()); }
                        commerce_records.insert(ref_fab, (idx + 1, map, line.to_string()));
                    }
                }
                "L" | "LOGISTIQUE" => {
                    // Structure typique L : L;REF_FAB;POIDS_NET;POIDS_BRUT;LONGUEUR;LARGEUR;HAUTEUR
                    if parts.len() >= 2 {
                        let ref_fab = parts[1].to_string();
                        let mut map = HashMap::new();
                        if parts.len() > 2 { map.insert("poids_net".to_string(), parts[2].to_string()); }
                        if parts.len() > 3 { map.insert("poids_brut".to_string(), parts[3].to_string()); }
                        if parts.len() > 4 { map.insert("longueur".to_string(), parts[4].to_string()); }
                        if parts.len() > 5 { map.insert("largeur".to_string(), parts[5].to_string()); }
                        if parts.len() > 6 { map.insert("hauteur".to_string(), parts[6].to_string()); }
                        logistics_records.insert(ref_fab, map);
                    }
                }
                "R" | "REGLEMENTATION" | "TECHNIQUE" => {
                    // Structure typique R : R;REF_FAB;ETIM;NORME;CLASSEMENT_FEU
                    if parts.len() >= 2 {
                        let ref_fab = parts[1].to_string();
                        let mut map = HashMap::new();
                        if parts.len() > 2 { map.insert("etim".to_string(), parts[2].to_string()); }
                        if parts.len() > 3 { map.insert("norme".to_string(), parts[3].to_string()); }
                        if parts.len() > 4 { map.insert("classement_feu".to_string(), parts[4].to_string()); }
                        reg_records.insert(ref_fab, map);
                    }
                }
                _ => {}
            }
        }

        let mut output = Vec::new();
        for (ref_fab, (line_num, c_map, raw_text)) in commerce_records {
            let ean = c_map.get("ean").cloned().filter(|s| !s.is_empty());
            let designation = c_map.get("designation").cloned().unwrap_or_else(|| format!("Article FAB-DIS {ref_fab}"));
            let brand = c_map.get("marque").cloned().filter(|s| !s.is_empty());
            let unit = c_map.get("unite").cloned().filter(|s| !s.is_empty());
            let price = c_map.get("prix").and_then(|p| p.replace(',', ".").parse::<f64>().ok());

            // Réconciliation logistique
            let mut dimensions = None;
            let mut weight = None;
            if let Some(l_map) = logistics_records.get(&ref_fab) {
                let length = l_map.get("longueur").and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                let width = l_map.get("largeur").and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                let height = l_map.get("hauteur").and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                if length.is_some() || width.is_some() || height.is_some() {
                    dimensions = Some(RawDimensionsDto {
                        length,
                        width,
                        height,
                        unit: Some("mm".to_string()),
                    });
                }

                let net_weight = l_map.get("poids_net").and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                let gross_weight = l_map.get("poids_brut").and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                if net_weight.is_some() || gross_weight.is_some() {
                    weight = Some(RawWeightDto {
                        net_weight,
                        gross_weight,
                        unit: Some("kg".to_string()),
                    });
                }
            }

            // Attributs techniques
            let mut raw_attrs = HashMap::new();
            if let Some(r_map) = reg_records.get(&ref_fab) {
                for (k, v) in r_map {
                    raw_attrs.insert(k.clone(), v.clone());
                }
            }

            let raw_hash = lyxal_crypto::blake3_hex(raw_text.as_bytes());
            let payload = json!({
                "format": "FAB-DIS_2.3",
                "commerce": c_map,
                "logistics": logistics_records.get(&ref_fab),
                "reglementation": reg_records.get(&ref_fab),
            });

            output.push(RawRecordDto {
                line_number: line_num,
                raw_reference: ref_fab,
                raw_designation: designation,
                raw_gtin: ean,
                raw_manufacturer: None,
                raw_brand: brand,
                raw_unit: unit,
                raw_price: price,
                raw_currency: Some("EUR".to_string()),
                raw_dimensions: dimensions,
                raw_weight: weight,
                raw_attributes: raw_attrs,
                raw_payload: payload,
                raw_hash,
            });
        }

        output.sort_by_key(|r| r.line_number);
        Ok(output)
    }

    /// Parse le format tabulaire FAB-DIS 3.0 unifié
    fn parse_tabular(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError> {
        let csv_adapter = super::csv::CsvAdapter::new();
        let mut records = csv_adapter.parse_content(content)?;
        
        // Enrichissement spécifique FAB-DIS 3.0
        for r in &mut records {
            if let Some(payload_obj) = r.raw_payload.as_object_mut() {
                payload_obj.insert("format".to_string(), json!("FAB-DIS_3.0"));
            }
        }
        Ok(records)
    }
}

#[async_trait]
impl SourceAdapter for FabDisAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::FabDis
    }

    fn supported_versions(&self) -> &'static [&'static str] {
        &["FAB-DIS 2.3", "FAB-DIS 3.0"]
    }

    fn validate_header(&self, sample: &[u8]) -> Result<(), IngestionError> {
        let text = std::str::from_utf8(sample).map_err(|e| {
            IngestionError::Validation(format!("Encodage FAB-DIS invalide (UTF-8 requis) : {e}"))
        })?;

        let sample_upper = text.to_uppercase();
        let has_fab_dis_markers = sample_upper.contains("REF_FAB")
            || sample_upper.contains("FAB-DIS")
            || sample_upper.contains("COMMERCE")
            || sample_upper.contains("REF_CONSTRUCTEUR")
            || sample_upper.contains("C;")
            || sample_upper.contains("C\t");

        if !has_fab_dis_markers {
            return Err(IngestionError::Validation(
                "Le fichier ne présente pas les en-têtes ou blocs caractéristiques du standard FAB-DIS (2.3 ou 3.0)".to_string(),
            ));
        }

        Ok(())
    }

    fn parse_content(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError> {
        if Self::is_multi_block(content) {
            self.parse_multi_block(content)
        } else {
            self.parse_tabular(content)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_fab_dis_multi_block_parsing() {
        let content = r#"
C;BA13_2500;3456789012345;Placoplatre BA13 2500x1200;PLACO;M2;8.50
L;BA13_2500;28.5;29.0;2500;1200;12.5
R;BA13_2500;EC001419;NF EN 520;A2-s1,d0
C;RAIL_R48;3456789012352;Rail Stil Prim R48 3m;PLACO;ML;3.20
L;RAIL_R48;1.5;1.6;3000;48;40
"#;
        let adapter = FabDisAdapter::new();
        let records = adapter.parse_content(content).unwrap();

        assert_eq!(records.len(), 2);
        
        // Vérification de la première référence réconciliée multi-blocs
        let ba13 = &records[0];
        assert_eq!(ba13.raw_reference, "BA13_2500");
        assert_eq!(ba13.raw_gtin, Some("3456789012345".to_string()));
        assert_eq!(ba13.raw_brand, Some("PLACO".to_string()));
        assert_eq!(ba13.raw_unit, Some("M2".to_string()));
        assert_eq!(ba13.raw_price, Some(8.50));

        let dims = ba13.raw_dimensions.as_ref().unwrap();
        assert_eq!(dims.length, Some(2500.0));
        assert_eq!(dims.width, Some(1200.0));
        assert_eq!(dims.height, Some(12.5));

        let weight = ba13.raw_weight.as_ref().unwrap();
        assert_eq!(weight.net_weight, Some(28.5));

        assert_eq!(ba13.raw_attributes.get("classement_feu"), Some(&"A2-s1,d0".to_string()));
        assert_eq!(ba13.raw_attributes.get("etim"), Some(&"EC001419".to_string()));

        // Deuxième référence
        let rail = &records[1];
        assert_eq!(rail.raw_reference, "RAIL_R48");
        assert_eq!(rail.raw_unit, Some("ML".to_string()));
    }

    #[test]
    fn test_fab_dis_tabular_3_0() {
        let content = "REF_FAB;EAN;LIBELLE_COMMERCIAL;MARQUE;PRIX_TARIF;UNITE_REF\nBA13;3456789012345;Placoplatre BA13;PLACO;8.50;M2\n";
        let adapter = FabDisAdapter::new();
        let records = adapter.parse_content(content).unwrap();

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "BA13");
        assert_eq!(records[0].raw_gtin, Some("3456789012345".to_string()));
        assert_eq!(records[0].raw_unit, Some("M2".to_string()));
    }
}
