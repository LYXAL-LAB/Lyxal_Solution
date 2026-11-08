//! Adaptateur XML : lecture par `lyxal_parsing` (BMEcat et catalogues hiérarchiques, entités
//! décodées, aucune entité externe), correspondance des balises vers [`RawRecordDto`].

use serde_json::json;
use std::collections::HashMap;

use lyxal_parsing::{XmlOptions, XmlReader, XmlRecord};

use super::{
    fields_hash, read_item, RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter, SourceItem,
};
use crate::error::IngestionError;
use crate::types::{SourceEncoding, SourceFormat};

/// Éléments qui forment un article.
const RECORD_ELEMENTS: [&str; 6] = ["ARTICLE", "PRODUCT", "ITEM", "article", "product", "item"];

/// Adaptateur XML (BMEcat 1.2 / 2005 et catalogues génériques).
#[derive(Debug, Clone, Default)]
pub struct XmlAdapter;

impl XmlAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Met en correspondance un article lu avec un [`RawRecordDto`].
    fn map_record(record: XmlRecord) -> RawRecordDto {
        let record = &record;
        let line_num = record.position.record as usize;
        // Référence produit
        let reference = tag(record, "SUPPLIER_AID")
            .or_else(|| tag(record, "supplier_aid"))
            .or_else(|| tag(record, "REF_FAB"))
            .or_else(|| tag(record, "REFERENCE"))
            .or_else(|| tag(record, "SKU"))
            .unwrap_or_else(|| format!("XML_ART_{line_num}"));

        // Désignation
        let designation = tag(record, "DESCRIPTION_SHORT")
            .or_else(|| tag(record, "DESCRIPTION"))
            .or_else(|| tag(record, "LIBELLE"))
            .or_else(|| tag(record, "NAME"))
            .unwrap_or_else(|| format!("Article XML {reference}"));

        // GTIN / EAN
        let gtin = tag(record, "INTERNATIONAL_AID")
            .or_else(|| tag(record, "EAN"))
            .or_else(|| tag(record, "GTIN"));

        // Fabricant et marque
        let manufacturer = tag(record, "MANUFACTURER_NAME").or_else(|| tag(record, "FABRICANT"));
        let brand = tag(record, "BRAND").or_else(|| tag(record, "MARQUE"));

        // Unité de commande
        let unit = tag(record, "ORDER_UNIT").or_else(|| tag(record, "UNITE"));

        // Prix
        let price = tag(record, "PRICE_AMOUNT")
            .or_else(|| tag(record, "PRIX"))
            .and_then(|p| p.replace(',', ".").parse::<f64>().ok());

        // Devise
        let currency = tag(record, "PRICE_CURRENCY")
            .or_else(|| tag(record, "CURRENCY"))
            .or_else(|| Some("EUR".to_string()));

        // Extraction attributs techniques simples
        let mut raw_attrs = HashMap::new();
        if let Some(etim) = tag(record, "REFERENCE_FEATURE_GROUP_ID") {
            raw_attrs.insert("etim_class".to_string(), etim);
        }
        if let Some(norm) = tag(record, "STANDARD") {
            raw_attrs.insert("norme".to_string(), norm);
        }

        // Dimensions si présentes
        let length = tag(record, "LENGTH").and_then(|v| v.parse::<f64>().ok());
        let width = tag(record, "WIDTH").and_then(|v| v.parse::<f64>().ok());
        let height = tag(record, "HEIGHT").and_then(|v| v.parse::<f64>().ok());
        let dimensions = if length.is_some() || width.is_some() || height.is_some() {
            Some(RawDimensionsDto {
                length,
                width,
                height,
                unit: Some("mm".to_string()),
            })
        } else {
            None
        };

        // Poids si présent
        let net_weight = tag(record, "WEIGHT").and_then(|v| v.parse::<f64>().ok());
        let weight = if net_weight.is_some() {
            Some(RawWeightDto {
                net_weight,
                gross_weight: None,
                unit: Some("kg".to_string()),
            })
        } else {
            None
        };

        let raw_hash = fields_hash(&record.fields);
        let payload = json!({
            "format": "XML_BMECAT",
            "line": record.position.line,
            "element": record.element,
            "fields": record.fields,
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
}

/// Valeur de la première balise nommée `name` (dernier segment du chemin), non vide, sans les
/// blancs qui l'entourent.
fn tag(record: &XmlRecord, name: &str) -> Option<String> {
    record.fields.iter().find_map(|(path, value)| {
        let leaf = path.rsplit('/').next().unwrap_or(path);
        let value = value.trim();
        (leaf == name && !value.is_empty()).then(|| value.to_string())
    })
}

impl SourceAdapter for XmlAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::Xml
    }

    fn read(
        &self,
        source: &[u8],
        encoding: SourceEncoding,
    ) -> Result<Vec<SourceItem>, IngestionError> {
        let options = XmlOptions {
            record_elements: RECORD_ELEMENTS.iter().map(|e| e.to_string()).collect(),
            encoding: encoding.parsing(),
            ..Default::default()
        };
        XmlReader::new(source, options)
            .map(|item| read_item(item, Self::map_record))
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_bmecat_xml_parsing() {
        let xml_content = r#"<?xml version="1.0" encoding="UTF-8"?>
<BMECAT version="1.2">
  <T_NEW_CATALOG>
    <ARTICLE>
      <SUPPLIER_AID>BA13-PREGYPLAC</SUPPLIER_AID>
      <INTERNATIONAL_AID>3456789012399</INTERNATIONAL_AID>
      <ARTICLE_DETAILS>
        <DESCRIPTION_SHORT>Plaque Siniat Pregyplac BA13 2500x1200</DESCRIPTION_SHORT>
        <MANUFACTURER_NAME>SINIAT</MANUFACTURER_NAME>
      </ARTICLE_DETAILS>
      <ARTICLE_ORDER_DETAILS>
        <ORDER_UNIT>M2</ORDER_UNIT>
      </ARTICLE_ORDER_DETAILS>
      <ARTICLE_PRICE_DETAILS>
        <ARTICLE_PRICE>
          <PRICE_AMOUNT>8.20</PRICE_AMOUNT>
          <PRICE_CURRENCY>EUR</PRICE_CURRENCY>
        </ARTICLE_PRICE>
      </ARTICLE_PRICE_DETAILS>
    </ARTICLE>
  </T_NEW_CATALOG>
</BMECAT>"#;

        let adapter = XmlAdapter::new();
        let records = crate::adapters::records_only(
            adapter
                .read(xml_content.as_bytes(), SourceEncoding::Utf8)
                .unwrap(),
        );

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "BA13-PREGYPLAC");
        assert_eq!(
            records[0].raw_designation,
            "Plaque Siniat Pregyplac BA13 2500x1200"
        );
        assert_eq!(records[0].raw_gtin, Some("3456789012399".to_string()));
        assert_eq!(records[0].raw_manufacturer, Some("SINIAT".to_string()));
        assert_eq!(records[0].raw_unit, Some("M2".to_string()));
        assert_eq!(records[0].raw_price, Some(8.20));
    }

    #[test]
    fn entities_are_decoded() {
        // A05 : les entités n'étaient pas décodées
        let xml_content = "<BMECAT><ARTICLE><SUPPLIER_AID>BA13&amp;co</SUPPLIER_AID><DESCRIPTION_SHORT>Plaque &#233;paisseur &lt;12,5&gt;</DESCRIPTION_SHORT></ARTICLE></BMECAT>";
        let records = crate::adapters::records_only(
            XmlAdapter::new()
                .read(xml_content.as_bytes(), SourceEncoding::Utf8)
                .unwrap(),
        );
        assert_eq!(records[0].raw_reference, "BA13&co");
        assert_eq!(records[0].raw_designation, "Plaque épaisseur <12,5>");
    }

    #[test]
    fn malformed_xml_makes_the_source_invalid() {
        let error = XmlAdapter::new()
            .read(
                b"<BMECAT><ARTICLE><SUPPLIER_AID>A</X></ARTICLE></BMECAT>",
                SourceEncoding::Utf8,
            )
            .unwrap_err();
        assert_eq!(error.code(), "INGESTION_SOURCE_INVALID");
    }
}
