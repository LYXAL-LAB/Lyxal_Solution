//! Adaptateur JSON pour formats tableaux JSON et flux NDJSON (JSON Lines).

use async_trait::async_trait;
use serde_json::Value;
use std::collections::HashMap;

use super::{RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter};
use crate::error::IngestionError;
use crate::types::SourceFormat;

/// Adaptateur JSON avec support combiné JSON Array et NDJSON streaming.
#[derive(Debug, Clone, Default)]
pub struct JsonAdapter;

impl JsonAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Détermine si le flux est un tableau JSON `[...]` ou un flux NDJSON (lignes d'objets `{...}\n{...}`)
    fn is_array_format(content: &str) -> bool {
        content.trim_start().starts_with('[')
    }

    /// Parse un objet JSON individuel en `RawRecordDto`
    fn parse_json_object(obj: &Value, line_num: usize) -> Option<RawRecordDto> {
        let map = obj.as_object()?;

        // Recherche flexible de la référence
        let reference = find_string(map, &["ref", "reference", "reference_fabricant", "sku", "id", "code_article"])
            .unwrap_or_else(|| format!("JSON_ART_{line_num}"));

        // Désignation
        let designation = find_string(map, &["designation", "libelle", "description", "label", "name", "nom"])
            .unwrap_or_else(|| format!("Article JSON {reference}"));

        // GTIN
        let gtin = find_string(map, &["ean", "ean13", "gtin", "barcode", "code_barre"]);

        // Fabricant et marque
        let manufacturer = find_string(map, &["fabricant", "manufacturer", "fournisseur", "supplier"]);
        let brand = find_string(map, &["marque", "brand"]);

        // Unité
        let unit = find_string(map, &["unite", "unit", "uom", "unite_vente"]);

        // Prix
        let price = find_f64(map, &["prix", "price", "tarif", "prix_ht"]);
        let currency = find_string(map, &["devise", "currency"]).or_else(|| Some("EUR".to_string()));

        // Dimensions
        let length = find_f64(map, &["longueur", "length", "long"]);
        let width = find_f64(map, &["largeur", "width", "larg"]);
        let height = find_f64(map, &["hauteur", "height", "epaisseur", "thickness"]);
        let dim_unit = find_string(map, &["unite_dim", "dim_unit"]).or_else(|| Some("mm".to_string()));

        let dimensions = if length.is_some() || width.is_some() || height.is_some() {
            Some(RawDimensionsDto {
                length,
                width,
                height,
                unit: dim_unit,
            })
        } else if let Some(dim_obj) = map.get("dimensions").and_then(|v| v.as_object()) {
            Some(RawDimensionsDto {
                length: find_f64(dim_obj, &["length", "longueur"]),
                width: find_f64(dim_obj, &["width", "largeur"]),
                height: find_f64(dim_obj, &["height", "hauteur", "epaisseur"]),
                unit: find_string(dim_obj, &["unit", "unite"]).or_else(|| Some("mm".to_string())),
            })
        } else {
            None
        };

        // Poids
        let gross_weight = find_f64(map, &["poids_brut", "gross_weight"]);
        let net_weight = find_f64(map, &["poids", "poids_net", "net_weight", "weight"]);
        let weight_unit = find_string(map, &["unite_poids", "weight_unit"]).or_else(|| Some("kg".to_string()));

        let weight = if gross_weight.is_some() || net_weight.is_some() {
            Some(RawWeightDto {
                gross_weight,
                net_weight,
                unit: weight_unit,
            })
        } else {
            None
        };

        // Attributs résiduels
        let mut raw_attrs = HashMap::new();
        for (k, v) in map {
            if let Some(s) = v.as_str() {
                raw_attrs.insert(k.clone(), s.to_string());
            } else if let Some(n) = v.as_f64() {
                raw_attrs.insert(k.clone(), n.to_string());
            } else if let Some(b) = v.as_bool() {
                raw_attrs.insert(k.clone(), b.to_string());
            }
        }

        let raw_hash = lyxal_crypto::blake3_hex(serde_json::to_string(obj).unwrap_or_default().as_bytes());

        Some(RawRecordDto {
            line_number: line_num,
            raw_reference: reference,
            raw_designation: designation,
            raw_gtin: gtin,
            raw_manufacturer: manufacturer,
            raw_brand: brand,
            raw_unit: unit,
            raw_price: price,
            raw_currency: currency,
            raw_dimensions: dimensions,
            raw_weight: weight,
            raw_attributes: raw_attrs,
            raw_payload: obj.clone(),
            raw_hash,
        })
    }
}

#[async_trait]
impl SourceAdapter for JsonAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::Json
    }

    fn supported_versions(&self) -> &'static [&'static str] {
        &["JSON-ARRAY", "NDJSON-STREAMING", "WEBHOOK-JSON"]
    }

    fn validate_header(&self, sample: &[u8]) -> Result<(), IngestionError> {
        let text = std::str::from_utf8(sample).map_err(|e| {
            IngestionError::Validation(format!("Encodage JSON invalide (UTF-8 requis) : {e}"))
        })?;

        let trimmed = text.trim_start();
        if !trimmed.starts_with('[') && !trimmed.starts_with('{') {
            return Err(IngestionError::Validation(
                "Le fichier n'est pas un flux JSON ou NDJSON valide (doit commencer par '[' ou '{')".to_string(),
            ));
        }

        Ok(())
    }

    fn parse_content(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError> {
        let trimmed = content.trim();
        if trimmed.is_empty() {
            return Ok(Vec::new());
        }

        if Self::is_array_format(trimmed) {
            // Format Tableau JSON
            let root: Value = serde_json::from_str(trimmed).map_err(|e| {
                IngestionError::Validation(format!("Erreur de syntaxe JSON dans le tableau : {e}"))
            })?;

            let array = root.as_array().ok_or_else(|| {
                IngestionError::Validation("La racine JSON n'est pas un tableau d'articles".to_string())
            })?;

            let mut records = Vec::with_capacity(array.len());
            for (idx, item) in array.iter().enumerate() {
                if let Some(record) = Self::parse_json_object(item, idx + 1) {
                    records.push(record);
                }
            }
            Ok(records)
        } else {
            // Format NDJSON / JSON Lines
            let mut records = Vec::new();
            for (idx, line) in trimmed.lines().enumerate() {
                let line_trim = line.trim();
                if line_trim.is_empty() {
                    continue;
                }
                let item: Value = serde_json::from_str(line_trim).map_err(|e| {
                    IngestionError::Validation(format!("Ligne {idx} : syntaxe NDJSON invalide : {e}"))
                })?;
                if let Some(record) = Self::parse_json_object(&item, idx + 1) {
                    records.push(record);
                }
            }
            Ok(records)
        }
    }
}

fn find_string(map: &serde_json::Map<String, Value>, candidates: &[&str]) -> Option<String> {
    for &c in candidates {
        for (k, v) in map {
            if k.eq_ignore_ascii_case(c) {
                if let Some(s) = v.as_str() {
                    let trimmed = s.trim();
                    if !trimmed.is_empty() {
                        return Some(trimmed.to_string());
                    }
                }
            }
        }
    }
    None
}

fn find_f64(map: &serde_json::Map<String, Value>, candidates: &[&str]) -> Option<f64> {
    for &c in candidates {
        for (k, v) in map {
            if k.eq_ignore_ascii_case(c) {
                if let Some(n) = v.as_f64() {
                    return Some(n);
                } else if let Some(s) = v.as_str() {
                    if let Ok(n) = s.replace(',', ".").trim().parse::<f64>() {
                        return Some(n);
                    }
                }
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_json_array_parsing() {
        let json_content = r#"[
            {
                "ref": "PRISE-2PT-BLANC",
                "designation": "Prise de courant 2P+T 16A encastré blanc",
                "ean": "3456789012444",
                "fabricant": "LEGRAND",
                "prix": 7.90,
                "unite": "PCE"
            }
        ]"#;

        let adapter = JsonAdapter::new();
        let records = adapter.parse_content(json_content).unwrap();

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "PRISE-2PT-BLANC");
        assert_eq!(records[0].raw_designation, "Prise de courant 2P+T 16A encastré blanc");
        assert_eq!(records[0].raw_gtin, Some("3456789012444".to_string()));
        assert_eq!(records[0].raw_manufacturer, Some("LEGRAND".to_string()));
        assert_eq!(records[0].raw_price, Some(7.90));
        assert_eq!(records[0].raw_unit, Some("PCE".to_string()));
    }

    #[test]
    fn test_ndjson_streaming_parsing() {
        let ndjson_content = "{\"ref\": \"R48-3M\", \"designation\": \"Rail R48 3m\", \"prix\": 3.20}\n{\"ref\": \"M48-3M\", \"designation\": \"Montant M48 3m\", \"prix\": 3.50}\n";

        let adapter = JsonAdapter::new();
        let records = adapter.parse_content(ndjson_content).unwrap();

        assert_eq!(records.len(), 2);
        assert_eq!(records[0].raw_reference, "R48-3M");
        assert_eq!(records[1].raw_reference, "M48-3M");
    }
}
