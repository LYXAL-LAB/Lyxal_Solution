//! Adaptateur JSON : lecture par `lyxal_parsing` (tableau d'objets ou NDJSON, élément non objet
//! rejeté), correspondance des clés vers [`RawRecordDto`].

use serde_json::Value;
use std::collections::HashMap;

use lyxal_parsing::{JsonOptions, JsonReader, JsonRecord};

use super::{read_item, RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter, SourceItem};
use crate::error::IngestionError;
use crate::types::{SourceEncoding, SourceFormat};

/// Adaptateur JSON (tableau d'objets ou NDJSON, disposition détectée).
#[derive(Debug, Clone, Default)]
pub struct JsonAdapter;

impl JsonAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Met en correspondance un objet lu avec un [`RawRecordDto`].
    fn map_record(record: JsonRecord) -> RawRecordDto {
        let line_num = record.position.record as usize;
        let map = &record.value;

        // Recherche flexible de la référence
        let reference = find_string(
            map,
            &[
                "ref",
                "reference",
                "reference_fabricant",
                "sku",
                "id",
                "code_article",
            ],
        )
        .unwrap_or_else(|| format!("JSON_ART_{line_num}"));

        // Désignation
        let designation = find_string(
            map,
            &[
                "designation",
                "libelle",
                "description",
                "label",
                "name",
                "nom",
            ],
        )
        .unwrap_or_else(|| format!("Article JSON {reference}"));

        // GTIN
        let gtin = find_string(map, &["ean", "ean13", "gtin", "barcode", "code_barre"]);

        // Fabricant et marque
        let manufacturer = find_string(
            map,
            &["fabricant", "manufacturer", "fournisseur", "supplier"],
        );
        let brand = find_string(map, &["marque", "brand"]);

        // Unité
        let unit = find_string(map, &["unite", "unit", "uom", "unite_vente"]);

        // Prix
        let price = find_f64(map, &["prix", "price", "tarif", "prix_ht"]);
        let currency =
            find_string(map, &["devise", "currency"]).or_else(|| Some("EUR".to_string()));

        // Dimensions
        let length = find_f64(map, &["longueur", "length", "long"]);
        let width = find_f64(map, &["largeur", "width", "larg"]);
        let height = find_f64(map, &["hauteur", "height", "epaisseur", "thickness"]);
        let dim_unit =
            find_string(map, &["unite_dim", "dim_unit"]).or_else(|| Some("mm".to_string()));

        let dimensions = if length.is_some() || width.is_some() || height.is_some() {
            Some(RawDimensionsDto {
                length,
                width,
                height,
                unit: dim_unit,
            })
        } else {
            map.get("dimensions")
                .and_then(|v| v.as_object())
                .map(|dim_obj| RawDimensionsDto {
                    length: find_f64(dim_obj, &["length", "longueur"]),
                    width: find_f64(dim_obj, &["width", "largeur"]),
                    height: find_f64(dim_obj, &["height", "hauteur", "epaisseur"]),
                    unit: find_string(dim_obj, &["unit", "unite"])
                        .or_else(|| Some("mm".to_string())),
                })
        };

        // Poids
        let gross_weight = find_f64(map, &["poids_brut", "gross_weight"]);
        let net_weight = find_f64(map, &["poids", "poids_net", "net_weight", "weight"]);
        let weight_unit =
            find_string(map, &["unite_poids", "weight_unit"]).or_else(|| Some("kg".to_string()));

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

        let obj = Value::Object(record.value.clone());
        let raw_hash = lyxal_crypto::blake3_hex(obj.to_string().as_bytes());

        RawRecordDto {
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
        }
    }
}

impl SourceAdapter for JsonAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::Json
    }

    fn read(
        &self,
        source: &[u8],
        encoding: SourceEncoding,
    ) -> Result<Vec<SourceItem>, IngestionError> {
        let options = JsonOptions {
            encoding: encoding.parsing(),
            ..Default::default()
        };
        JsonReader::new(source, options)
            .map(|item| read_item(item, Self::map_record))
            .collect()
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
    use crate::adapters::records_only;

    fn read(content: &str) -> Result<Vec<SourceItem>, IngestionError> {
        JsonAdapter::new().read(content.as_bytes(), SourceEncoding::Utf8)
    }

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

        let records = records_only(read(json_content).unwrap());

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "PRISE-2PT-BLANC");
        assert_eq!(
            records[0].raw_designation,
            "Prise de courant 2P+T 16A encastré blanc"
        );
        assert_eq!(records[0].raw_gtin, Some("3456789012444".to_string()));
        assert_eq!(records[0].raw_manufacturer, Some("LEGRAND".to_string()));
        assert_eq!(records[0].raw_price, Some(7.90));
        assert_eq!(records[0].raw_unit, Some("PCE".to_string()));
    }

    #[test]
    fn test_ndjson_streaming_parsing() {
        let ndjson_content = "{\"ref\": \"R48-3M\", \"designation\": \"Rail R48 3m\", \"prix\": 3.20}\n{\"ref\": \"M48-3M\", \"designation\": \"Montant M48 3m\", \"prix\": 3.50}\n";

        let records = records_only(read(ndjson_content).unwrap());

        assert_eq!(records.len(), 2);
        assert_eq!(records[0].raw_reference, "R48-3M");
        assert_eq!(records[1].raw_reference, "M48-3M");
    }

    #[test]
    fn non_object_elements_are_rejected_not_ignored() {
        // A05 : ces éléments étaient ignorés sans trace
        let items = read(r#"[{"ref":"A"}, 42, {"ref":"B"}]"#).unwrap();
        assert_eq!(items.len(), 3);
        let SourceItem::Rejected(rejection) = &items[1] else {
            panic!("rejet attendu");
        };
        assert_eq!(rejection.record, 2);
        assert_eq!(rejection.cause_code, "PARSING_JSON_NOT_OBJECT");
        assert_eq!(items[2].number(), 3);
    }

    #[test]
    fn broken_array_makes_the_source_invalid() {
        let error = read(r#"[{"ref":"A"}, {"ref":"#).unwrap_err();
        assert_eq!(error.code(), "INGESTION_SOURCE_INVALID");
    }
}
