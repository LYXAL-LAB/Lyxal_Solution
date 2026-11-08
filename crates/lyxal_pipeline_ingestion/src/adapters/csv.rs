//! Adaptateur CSV : lecture par `lyxal_parsing` (champs entre guillemets sur plusieurs lignes,
//! séparateur détecté, rejets explicites), correspondance des colonnes vers [`RawRecordDto`].

use serde_json::json;
use std::collections::HashMap;

use lyxal_parsing::{CsvOptions, CsvReader, CsvRecord, Delimiter};

use super::{
    fields_hash, read_item, source_invalid, RawDimensionsDto, RawRecordDto, RawWeightDto,
    SourceAdapter, SourceItem,
};
use crate::error::IngestionError;
use crate::types::{SourceEncoding, SourceFormat};

/// Adaptateur CSV avec détection automatique du séparateur (`;`, `,`, tabulation, `|`).
#[derive(Debug, Clone, Default)]
pub struct CsvAdapter;

impl CsvAdapter {
    /// Crée un adaptateur CSV (séparateur détecté sur l'en-tête).
    pub fn new() -> Self {
        Self
    }

    /// Met en correspondance un enregistrement lu (colonnes de l'en-tête) avec un
    /// [`RawRecordDto`] ; `format` est repris dans `raw_payload`.
    pub(crate) fn map_record(record: &CsvRecord, format: &str) -> RawRecordDto {
        let line_num = record.position.record as usize;
        let fields: Vec<String> = record
            .fields
            .iter()
            .map(|(_, value)| value.clone())
            .collect();
        let header_map: HashMap<String, usize> = record
            .fields
            .iter()
            .enumerate()
            .map(|(idx, (name, _))| (normalize_col_name(name), idx))
            .collect();

        // Recherche flexible des colonnes fondamentales
        let reference = find_field(
            &fields,
            &header_map,
            &[
                "ref",
                "reference",
                "reference_fabricant",
                "ref_fab",
                "art_code",
                "sku",
                "code_article",
            ],
        )
        .unwrap_or_else(|| format!("LIGNE_{line_num}"));

        let designation = find_field(
            &fields,
            &header_map,
            &[
                "designation",
                "libelle",
                "libelle_commercial",
                "description",
                "label",
                "nom",
                "titre",
            ],
        )
        .unwrap_or_else(|| format!("Article sans libellé {reference}"));

        let gtin = find_field(
            &fields,
            &header_map,
            &["ean", "ean13", "gtin", "code_barre", "barcode"],
        );
        let manufacturer = find_field(
            &fields,
            &header_map,
            &["fabricant", "manufacturer", "fournisseur", "supplier"],
        );
        let brand = find_field(&fields, &header_map, &["marque", "brand"]);
        let unit = find_field(
            &fields,
            &header_map,
            &["unite", "unit", "uom", "unite_vente", "unite_ref"],
        );

        let price = find_field(
            &fields,
            &header_map,
            &["prix", "price", "tarif", "prix_ht", "pu_ht"],
        )
        .and_then(|p| p.replace(',', ".").parse::<f64>().ok());

        let currency = find_field(&fields, &header_map, &["devise", "currency"])
            .or_else(|| Some("EUR".to_string()));

        // Extraction dimensions
        let length = find_field(&fields, &header_map, &["longueur", "length", "long"])
            .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
        let width = find_field(&fields, &header_map, &["largeur", "width", "larg"])
            .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
        let height = find_field(
            &fields,
            &header_map,
            &["hauteur", "height", "epaisseur", "thickness", "haut"],
        )
        .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
        let dim_unit = find_field(&fields, &header_map, &["unite_dim", "dim_unit"])
            .or_else(|| Some("mm".to_string()));

        let dimensions = if length.is_some() || width.is_some() || height.is_some() {
            Some(RawDimensionsDto {
                length,
                width,
                height,
                unit: dim_unit,
            })
        } else {
            None
        };

        // Extraction poids
        let gross_weight = find_field(&fields, &header_map, &["poids_brut", "gross_weight"])
            .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
        let net_weight = find_field(
            &fields,
            &header_map,
            &["poids", "poids_net", "net_weight", "weight"],
        )
        .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
        let weight_unit = find_field(&fields, &header_map, &["unite_poids", "weight_unit"])
            .or_else(|| Some("kg".to_string()));

        let weight = if gross_weight.is_some() || net_weight.is_some() {
            Some(RawWeightDto {
                gross_weight,
                net_weight,
                unit: weight_unit,
            })
        } else {
            None
        };

        // Collecte de l'ensemble des attributs bruts
        let mut raw_attrs = HashMap::new();
        for (col_name, &col_idx) in &header_map {
            if let Some(val) = fields.get(col_idx) {
                if !val.is_empty() {
                    raw_attrs.insert(col_name.clone(), val.clone());
                }
            }
        }

        let columns: serde_json::Map<String, serde_json::Value> = record
            .fields
            .iter()
            .map(|(name, value)| (name.clone(), json!(value)))
            .collect();
        let raw_hash = fields_hash(&record.fields);
        let payload = json!({
            "source": format,
            "line": record.position.line,
            "fields": columns,
        });

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
            raw_payload: payload,
            raw_hash,
        }
    }

    /// Lit une source CSV et met en correspondance chaque enregistrement ; `format` est repris
    /// dans `raw_payload` (FAB-DIS 3.0 tabulaire réutilise cette lecture).
    pub(crate) fn read_with_format(
        source: &[u8],
        encoding: SourceEncoding,
        format: &str,
    ) -> Result<Vec<SourceItem>, IngestionError> {
        let options = CsvOptions {
            delimiter: Delimiter::Auto,
            encoding: encoding.parsing(),
            ..Default::default()
        };
        let reader = CsvReader::new(source, options).map_err(source_invalid)?;
        reader
            .map(|item| read_item(item, |record| Self::map_record(&record, format)))
            .collect()
    }
}

impl SourceAdapter for CsvAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::Csv
    }

    fn read(
        &self,
        source: &[u8],
        encoding: SourceEncoding,
    ) -> Result<Vec<SourceItem>, IngestionError> {
        Self::read_with_format(source, encoding, "CSV")
    }
}

fn normalize_col_name(name: &str) -> String {
    name.trim()
        .to_lowercase()
        .replace([' ', '-', '_', '.', '/', '\\'], "")
}

fn find_field(
    fields: &[String],
    header_map: &HashMap<String, usize>,
    candidates: &[&str],
) -> Option<String> {
    for &candidate in candidates {
        let norm_cand = normalize_col_name(candidate);
        if let Some(&idx) = header_map.get(&norm_cand) {
            if let Some(val) = fields.get(idx) {
                let trimmed = val.trim();
                if !trimmed.is_empty() {
                    return Some(trimmed.to_string());
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
        CsvAdapter::new().read(content.as_bytes(), SourceEncoding::Utf8)
    }

    #[test]
    fn test_csv_semicolon_parsing() {
        let csv_content = "REF;DESIGNATION;EAN;PRIX;UNITE\nBA13_2500;Placoplatre BA13 2500x1200;3456789012345;8,50;M2\nRAIL_R48;Rail Stil Prim R48 3m;3456789012352;3,20;ML\n";
        let records = records_only(read(csv_content).unwrap());

        assert_eq!(records.len(), 2);
        assert_eq!(records[0].raw_reference, "BA13_2500");
        assert_eq!(records[0].raw_designation, "Placoplatre BA13 2500x1200");
        assert_eq!(records[0].raw_gtin, Some("3456789012345".to_string()));
        assert_eq!(records[0].raw_price, Some(8.50));
        assert_eq!(records[0].raw_unit, Some("M2".to_string()));
        assert_eq!(records[0].line_number, 1);

        assert_eq!(records[1].raw_reference, "RAIL_R48");
        assert_eq!(records[1].raw_price, Some(3.20));
    }

    #[test]
    fn test_csv_quoted_values_with_commas() {
        let csv_content = "ref,designation,prix\n\"REF-001\",\"Vis placo, boite de 1000\",12.90\n";
        let records = records_only(read(csv_content).unwrap());

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "REF-001");
        assert_eq!(records[0].raw_designation, "Vis placo, boite de 1000");
        assert_eq!(records[0].raw_price, Some(12.90));
    }

    #[test]
    fn multiline_quoted_designation_is_one_record() {
        // A05 : la lecture ligne par ligne découpait cette désignation en plusieurs articles
        let csv_content =
            "ref;designation;prix\nBA13;\"Plaque\nde plâtre\nstandard\";8,50\nBA18;Plaque;9,10\n";
        let items = read(csv_content).unwrap();
        assert_eq!(items.len(), 2);
        let SourceItem::Record(first) = &items[0] else {
            panic!("enregistrement attendu");
        };
        assert_eq!(first.raw_designation, "Plaque\nde plâtre\nstandard");
        assert_eq!(first.raw_payload["line"], 2);
        assert_eq!(items[1].number(), 2);
    }

    #[test]
    fn wrong_field_count_becomes_a_rejection_with_its_number() {
        let items = read("ref;prix\nA;1\nB\nC;3\n").unwrap();
        assert_eq!(items.len(), 3);
        let SourceItem::Rejected(rejection) = &items[1] else {
            panic!("rejet attendu");
        };
        assert_eq!(rejection.record, 2);
        assert_eq!(rejection.source_line, Some(3));
        assert_eq!(rejection.anomaly_code, "INGESTION_SOURCE_RECORD_REJECTED");
        assert_eq!(rejection.cause_code, "PARSING_CSV_FIELD_COUNT");
        assert_eq!(items[2].number(), 3);
    }

    #[test]
    fn invalid_header_makes_the_source_invalid() {
        let error = read("ref;;prix\nA;1;2\n").unwrap_err();
        assert_eq!(error.code(), "INGESTION_SOURCE_INVALID");
        assert!(
            error.to_string().contains("PARSING_HEADER_INVALID"),
            "{error}"
        );
    }

    #[test]
    fn declared_windows_1252_is_decoded() {
        let items = CsvAdapter::new()
            .read(
                b"ref;designation\nA;Caf\xE9 \x80\n",
                SourceEncoding::Windows1252,
            )
            .unwrap();
        let records = records_only(items);
        assert_eq!(records[0].raw_designation, "Café €");
    }
}
