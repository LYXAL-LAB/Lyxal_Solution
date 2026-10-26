//! Adaptateur CSV conforme RFC 4180 avec délimiteur dynamique et streaming tolérant.

use async_trait::async_trait;
use serde_json::json;
use std::collections::HashMap;

use super::{RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter};
use crate::error::IngestionError;
use crate::types::SourceFormat;

/// Adaptateur CSV avec détection automatique du délimiteur (virgule, point-virgule, tabulation, pipe).
#[derive(Debug, Clone, Default)]
pub struct CsvAdapter {
    delimiter_override: Option<char>,
}

impl CsvAdapter {
    /// Crée un nouvel adaptateur CSV avec auto-détection du délimiteur
    pub fn new() -> Self {
        Self {
            delimiter_override: None,
        }
    }

    /// Crée un adaptateur CSV avec délimiteur forcé
    pub fn with_delimiter(delimiter: char) -> Self {
        Self {
            delimiter_override: Some(delimiter),
        }
    }

    /// Détecte le délimiteur le plus probable à partir d'un échantillon
    pub fn detect_delimiter(&self, sample: &str) -> char {
        if let Some(d) = self.delimiter_override {
            return d;
        }

        let candidates = [';', ',', '\t', '|'];
        let mut best_delimiter = ';';
        let mut max_count = 0;

        let first_lines: Vec<&str> = sample.lines().take(5).collect();
        for &c in &candidates {
            let mut total_occurrences = 0;
            for line in &first_lines {
                total_occurrences += line.matches(c).count();
            }
            if total_occurrences > max_count {
                max_count = total_occurrences;
                best_delimiter = c;
            }
        }

        best_delimiter
    }

    /// Parse une ligne CSV en respectant les guillemets RFC 4180
    pub fn parse_csv_line(line: &str, delimiter: char) -> Vec<String> {
        let mut fields = Vec::new();
        let mut current_field = String::new();
        let mut in_quotes = false;
        let mut chars = line.chars().peekable();

        while let Some(ch) = chars.next() {
            if ch == '"' {
                if in_quotes && chars.peek() == Some(&'"') {
                    // Guillemet échappé ("")
                    chars.next();
                    current_field.push('"');
                } else {
                    in_quotes = !in_quotes;
                }
            } else if ch == delimiter && !in_quotes {
                fields.push(current_field.trim().to_string());
                current_field = String::new();
            } else {
                current_field.push(ch);
            }
        }
        fields.push(current_field.trim().to_string());
        fields
    }
}

#[async_trait]
impl SourceAdapter for CsvAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::Csv
    }

    fn supported_versions(&self) -> &'static [&'static str] {
        &["RFC4180", "EXCEL-CSV-FR", "CUSTOM-DELIMITED"]
    }

    fn validate_header(&self, sample: &[u8]) -> Result<(), IngestionError> {
        let text = std::str::from_utf8(sample).map_err(|e| {
            IngestionError::Validation(format!("Encodage de fichier CSV invalide (UTF-8 requis) : {e}"))
        })?;

        let first_line = text.lines().next().unwrap_or("");
        if first_line.trim().is_empty() {
            return Err(IngestionError::Validation(
                "Le fichier CSV est vide ou ne comporte aucun en-tête valide".to_string(),
            ));
        }

        let delimiter = self.detect_delimiter(first_line);
        let fields = Self::parse_csv_line(first_line, delimiter);
        if fields.is_empty() {
            return Err(IngestionError::Validation(
                "Impossible d'extraire les colonnes de l'en-tête CSV".to_string(),
            ));
        }

        Ok(())
    }

    fn parse_content(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError> {
        let mut lines = content.lines().enumerate();
        let first_line = match lines.next() {
            Some((_, line)) if !line.trim().is_empty() => line,
            _ => return Ok(Vec::new()),
        };

        let delimiter = self.detect_delimiter(first_line);
        let headers = Self::parse_csv_line(first_line, delimiter);

        // Indexation normalisée des colonnes d'en-tête (en minuscules sans accents/espaces)
        let header_map: HashMap<String, usize> = headers
            .into_iter()
            .enumerate()
            .map(|(idx, h)| (normalize_col_name(&h), idx))
            .collect();

        let mut records = Vec::new();

        for (row_idx, line) in lines {
            let trimmed = line.trim();
            if trimmed.is_empty() {
                continue;
            }

            let fields = Self::parse_csv_line(line, delimiter);
            let line_num = row_idx + 1; // 1-indexé

            // Recherche flexible des colonnes fondamentales
            let reference = find_field(&fields, &header_map, &["ref", "reference", "reference_fabricant", "ref_fab", "art_code", "sku", "code_article"])
                .unwrap_or_else(|| format!("LIGNE_{line_num}"));

            let designation = find_field(&fields, &header_map, &["designation", "libelle", "libelle_commercial", "description", "label", "nom", "titre"])
                .unwrap_or_else(|| format!("Article sans libellé {reference}"));

            let gtin = find_field(&fields, &header_map, &["ean", "ean13", "gtin", "code_barre", "barcode"]);
            let manufacturer = find_field(&fields, &header_map, &["fabricant", "manufacturer", "fournisseur", "supplier"]);
            let brand = find_field(&fields, &header_map, &["marque", "brand"]);
            let unit = find_field(&fields, &header_map, &["unite", "unit", "uom", "unite_vente", "unite_ref"]);

            let price = find_field(&fields, &header_map, &["prix", "price", "tarif", "prix_ht", "pu_ht"])
                .and_then(|p| p.replace(',', ".").parse::<f64>().ok());

            let currency = find_field(&fields, &header_map, &["devise", "currency"]).or_else(|| Some("EUR".to_string()));

            // Extraction dimensions
            let length = find_field(&fields, &header_map, &["longueur", "length", "long"]).and_then(|v| v.replace(',', ".").parse::<f64>().ok());
            let width = find_field(&fields, &header_map, &["largeur", "width", "larg"]).and_then(|v| v.replace(',', ".").parse::<f64>().ok());
            let height = find_field(&fields, &header_map, &["hauteur", "height", "epaisseur", "thickness", "haut"]).and_then(|v| v.replace(',', ".").parse::<f64>().ok());
            let dim_unit = find_field(&fields, &header_map, &["unite_dim", "dim_unit"]).or_else(|| Some("mm".to_string()));

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
            let gross_weight = find_field(&fields, &header_map, &["poids_brut", "gross_weight"]).and_then(|v| v.replace(',', ".").parse::<f64>().ok());
            let net_weight = find_field(&fields, &header_map, &["poids", "poids_net", "net_weight", "weight"]).and_then(|v| v.replace(',', ".").parse::<f64>().ok());
            let weight_unit = find_field(&fields, &header_map, &["unite_poids", "weight_unit"]).or_else(|| Some("kg".to_string()));

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

            let raw_hash = lyxal_crypto::blake3_hex(line.as_bytes());
            let payload = json!({
                "source": "CSV",
                "line": line_num,
                "fields": fields,
                "raw_text": line,
            });

            records.push(RawRecordDto {
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
            });
        }

        Ok(records)
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

    #[test]
    fn test_csv_semicolon_parsing() {
        let csv_content = "REF;DESIGNATION;EAN;PRIX;UNITE\nBA13_2500;Placoplatre BA13 2500x1200;3456789012345;8,50;M2\nRAIL_R48;Rail Stil Prim R48 3m;3456789012352;3,20;ML\n";
        let adapter = CsvAdapter::new();
        let records = adapter.parse_content(csv_content).unwrap();

        assert_eq!(records.len(), 2);
        assert_eq!(records[0].raw_reference, "BA13_2500");
        assert_eq!(records[0].raw_designation, "Placoplatre BA13 2500x1200");
        assert_eq!(records[0].raw_gtin, Some("3456789012345".to_string()));
        assert_eq!(records[0].raw_price, Some(8.50));
        assert_eq!(records[0].raw_unit, Some("M2".to_string()));

        assert_eq!(records[1].raw_reference, "RAIL_R48");
        assert_eq!(records[1].raw_price, Some(3.20));
    }

    #[test]
    fn test_csv_quoted_values_with_commas() {
        let csv_content = "ref,designation,prix\n\"REF-001\",\"Vis placo, boite de 1000\",12.90\n";
        let adapter = CsvAdapter::new();
        let records = adapter.parse_content(csv_content).unwrap();

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "REF-001");
        assert_eq!(records[0].raw_designation, "Vis placo, boite de 1000");
        assert_eq!(records[0].raw_price, Some(12.90));
    }
}
