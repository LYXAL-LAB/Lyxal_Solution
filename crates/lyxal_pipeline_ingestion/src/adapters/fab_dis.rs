//! Adaptateur FAB-DIS conforme aux standards BTP FAB-DIS 2.3 et FAB-DIS 3.0.
//!
//! La lecture est faite par `lyxal_parsing` (guillemets respectés, encodage déclaré) :
//! - FAB-DIS 2.3 : blocs sans en-tête (Commerce [C], Logistique [L], Média [M], Réglementaire
//!   [R]) regroupés par référence fabricant ;
//! - FAB-DIS 3.0 : tabulaire unifié, lu comme un CSV à en-tête.

use serde_json::json;
use std::collections::HashMap;

use lyxal_parsing::{CsvHeader, CsvOptions, CsvReader, CsvRecord, ReadFailure};

use super::csv::CsvAdapter;
use super::{
    fields_hash, source_invalid, RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter,
    SourceItem, SourceRejection,
};
use crate::error::IngestionError;
use crate::types::{SourceEncoding, SourceFormat};

/// Bloc FAB-DIS 2.3 invalide : orphelin, en double, sans référence ou de type inconnu.
const BLOCK_INVALID: &str = "INGESTION_FABDIS_BLOCK_INVALID";

/// Ligne commerciale retenue : numéro, ligne physique, champs nommés, champs lus.
type Commerce = (
    usize,
    Option<u64>,
    HashMap<String, String>,
    Vec<(String, String)>,
);

/// Adaptateur officiel pour les catalogues au format standard FAB-DIS.
#[derive(Debug, Clone, Default)]
pub struct FabDisAdapter;

impl FabDisAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Détermine si le flux est au format multi-blocs (lignes préfixées C, L, M, R) ou tabulaire
    /// (marqueurs ASCII cherchés dans le début de la source, quel que soit son encodage).
    fn is_multi_block(source: &[u8]) -> bool {
        let sample = String::from_utf8_lossy(&source[..source.len().min(16 * 1024)]);
        for line in sample.lines().take(15) {
            let trimmed = line.trim().trim_start_matches('\u{feff}');
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

    /// Champs d'un bloc à partir de la troisième colonne (après type et référence).
    fn block_fields(record: &CsvRecord, names: &[&str]) -> HashMap<String, String> {
        names
            .iter()
            .enumerate()
            .filter_map(|(offset, name)| {
                record
                    .fields
                    .get(offset + 2)
                    .map(|(_, value)| (name.to_string(), value.trim().to_string()))
            })
            .collect()
    }

    /// Parse le format multi-blocs FAB-DIS 2.3
    fn read_multi_block(
        source: &[u8],
        encoding: SourceEncoding,
    ) -> Result<Vec<SourceItem>, IngestionError> {
        let options = CsvOptions {
            header: CsvHeader::None,
            encoding: encoding.parsing(),
            ..Default::default()
        };
        let reader = CsvReader::new(source, options).map_err(source_invalid)?;

        let mut rejections: Vec<SourceRejection> = Vec::new();
        let mut commerce_records: Vec<(String, Commerce)> = Vec::new();
        let mut logistics_records: HashMap<String, HashMap<String, String>> = HashMap::new();
        let mut reg_records: HashMap<String, HashMap<String, String>> = HashMap::new();
        // Blocs L et R lus, rattachés à leur ligne C après lecture complète
        let mut dependents: Vec<(String, usize, Option<u64>)> = Vec::new();

        for item in reader {
            let record = match item {
                Ok(record) => record,
                Err(ReadFailure::Rejected(rejection)) => {
                    rejections.push(SourceRejection::from_parsing(rejection));
                    continue;
                }
                Err(ReadFailure::Fatal(error)) => return Err(source_invalid(error)),
            };
            let number = record.position.record as usize;
            let line = record.position.line;
            let reject = |detail: String| SourceRejection {
                record: number,
                source_line: line,
                anomaly_code: BLOCK_INVALID,
                cause_code: BLOCK_INVALID.to_string(),
                detail,
            };
            let block_type = record
                .fields
                .first()
                .map(|(_, value)| value.trim().to_uppercase())
                .unwrap_or_default();
            // Commentaire, ou bloc Média (non exploité par l'ingestion)
            if block_type.starts_with('#') || block_type == "M" || block_type == "MEDIA" {
                continue;
            }
            let reference = record
                .fields
                .get(1)
                .map(|(_, value)| value.trim().to_string())
                .unwrap_or_default();
            if reference.is_empty() {
                rejections.push(reject(format!(
                    "bloc « {block_type} » sans référence fabricant"
                )));
                continue;
            }
            match block_type.as_str() {
                // Structure typique C : C;REF_FAB;EAN;DESIGNATION;MARQUE;UNITE;PRIX
                "C" | "COMMERCE" => {
                    if commerce_records.iter().any(|(r, _)| *r == reference) {
                        rejections.push(reject(format!(
                            "bloc commercial en double pour la référence « {reference} »"
                        )));
                        continue;
                    }
                    let mut map = Self::block_fields(
                        &record,
                        &["ean", "designation", "marque", "unite", "prix"],
                    );
                    map.insert("ref_fab".to_string(), reference.clone());
                    commerce_records.push((reference, (number, line, map, record.fields)));
                }
                // Structure typique L : L;REF_FAB;POIDS_NET;POIDS_BRUT;LONGUEUR;LARGEUR;HAUTEUR
                "L" | "LOGISTIQUE" => {
                    if logistics_records.contains_key(&reference) {
                        rejections.push(reject(format!(
                            "bloc logistique en double pour la référence « {reference} »"
                        )));
                        continue;
                    }
                    let map = Self::block_fields(
                        &record,
                        &["poids_net", "poids_brut", "longueur", "largeur", "hauteur"],
                    );
                    logistics_records.insert(reference.clone(), map);
                    dependents.push((reference, number, line));
                }
                // Structure typique R : R;REF_FAB;ETIM;NORME;CLASSEMENT_FEU
                "R" | "REGLEMENTATION" | "TECHNIQUE" => {
                    if reg_records.contains_key(&reference) {
                        rejections.push(reject(format!(
                            "bloc réglementaire en double pour la référence « {reference} »"
                        )));
                        continue;
                    }
                    let map = Self::block_fields(&record, &["etim", "norme", "classement_feu"]);
                    reg_records.insert(reference.clone(), map);
                    dependents.push((reference, number, line));
                }
                other => {
                    rejections.push(reject(format!("type de bloc « {other} » inconnu")));
                }
            }
        }

        // Un bloc L ou R sans bloc C de même référence n'est jamais ignoré
        for (reference, number, line) in dependents {
            if !commerce_records.iter().any(|(r, _)| *r == reference) {
                logistics_records.remove(&reference);
                reg_records.remove(&reference);
                rejections.push(SourceRejection {
                    record: number,
                    source_line: line,
                    anomaly_code: BLOCK_INVALID,
                    cause_code: BLOCK_INVALID.to_string(),
                    detail: format!(
                        "bloc sans bloc commercial (C) pour la référence « {reference} »"
                    ),
                });
            }
        }

        let mut items: Vec<SourceItem> = rejections.into_iter().map(SourceItem::Rejected).collect();
        for (ref_fab, commerce) in commerce_records {
            let (line_num, source_line, c_map, raw_fields) = commerce;
            let ean = c_map.get("ean").cloned().filter(|s| !s.is_empty());
            let designation = c_map
                .get("designation")
                .cloned()
                .unwrap_or_else(|| format!("Article FAB-DIS {ref_fab}"));
            let brand = c_map.get("marque").cloned().filter(|s| !s.is_empty());
            let unit = c_map.get("unite").cloned().filter(|s| !s.is_empty());
            let price = c_map
                .get("prix")
                .and_then(|p| p.replace(',', ".").parse::<f64>().ok());

            // Réconciliation logistique
            let mut dimensions = None;
            let mut weight = None;
            if let Some(l_map) = logistics_records.get(&ref_fab) {
                let length = l_map
                    .get("longueur")
                    .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                let width = l_map
                    .get("largeur")
                    .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                let height = l_map
                    .get("hauteur")
                    .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                if length.is_some() || width.is_some() || height.is_some() {
                    dimensions = Some(RawDimensionsDto {
                        length,
                        width,
                        height,
                        unit: Some("mm".to_string()),
                    });
                }

                let net_weight = l_map
                    .get("poids_net")
                    .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
                let gross_weight = l_map
                    .get("poids_brut")
                    .and_then(|v| v.replace(',', ".").parse::<f64>().ok());
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

            let raw_hash = fields_hash(&raw_fields);
            let payload = json!({
                "format": "FAB-DIS_2.3",
                "line": source_line,
                "commerce": c_map,
                "logistics": logistics_records.get(&ref_fab),
                "reglementation": reg_records.get(&ref_fab),
            });

            items.push(SourceItem::Record(Box::new(RawRecordDto {
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
            })));
        }

        items.sort_by_key(SourceItem::number);
        Ok(items)
    }
}

impl SourceAdapter for FabDisAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::FabDis
    }

    fn read(
        &self,
        source: &[u8],
        encoding: SourceEncoding,
    ) -> Result<Vec<SourceItem>, IngestionError> {
        if Self::is_multi_block(source) {
            Self::read_multi_block(source, encoding)
        } else {
            CsvAdapter::read_with_format(source, encoding, "FAB-DIS_3.0")
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
        let records = crate::adapters::records_only(
            adapter
                .read(content.as_bytes(), SourceEncoding::Utf8)
                .unwrap(),
        );

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

        assert_eq!(
            ba13.raw_attributes.get("classement_feu"),
            Some(&"A2-s1,d0".to_string())
        );
        assert_eq!(
            ba13.raw_attributes.get("etim"),
            Some(&"EC001419".to_string())
        );

        // Deuxième référence
        let rail = &records[1];
        assert_eq!(rail.raw_reference, "RAIL_R48");
        assert_eq!(rail.raw_unit, Some("ML".to_string()));
    }

    #[test]
    fn test_fab_dis_tabular_3_0() {
        let content = "REF_FAB;EAN;LIBELLE_COMMERCIAL;MARQUE;PRIX_TARIF;UNITE_REF\nBA13;3456789012345;Placoplatre BA13;PLACO;8.50;M2\n";
        let adapter = FabDisAdapter::new();
        let records = crate::adapters::records_only(
            adapter
                .read(content.as_bytes(), SourceEncoding::Utf8)
                .unwrap(),
        );

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "BA13");
        assert_eq!(records[0].raw_gtin, Some("3456789012345".to_string()));
        assert_eq!(records[0].raw_unit, Some("M2".to_string()));
    }

    #[test]
    fn quoted_field_and_orphan_block() {
        let content = "C;BA13;3456789012345;\"Plaque; standard\";PLACO;M2;8.50\nL;RAIL;1.5;1.6;3000;48;40\nX;BA13\n";
        let items = FabDisAdapter::new()
            .read(content.as_bytes(), SourceEncoding::Utf8)
            .unwrap();
        assert_eq!(items.len(), 3);
        let SourceItem::Record(ba13) = &items[0] else {
            panic!("article attendu");
        };
        assert_eq!(ba13.raw_designation, "Plaque; standard");
        for (index, expected) in [(1, "sans bloc commercial"), (2, "inconnu")] {
            let SourceItem::Rejected(rejection) = &items[index] else {
                panic!("rejet attendu");
            };
            assert_eq!(rejection.anomaly_code, "INGESTION_FABDIS_BLOCK_INVALID");
            assert_eq!(rejection.record, index + 1);
            assert!(rejection.detail.contains(expected), "{}", rejection.detail);
        }
    }
}
