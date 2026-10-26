//! Adaptateur XML pour formats catalogues industriels et BMEcat 1.2 / 2005.

use async_trait::async_trait;
use serde_json::json;
use std::collections::HashMap;

use super::{RawDimensionsDto, RawRecordDto, RawWeightDto, SourceAdapter};
use crate::error::IngestionError;
use crate::types::SourceFormat;

/// Adaptateur XML avec parseur streaming par balises d'articles.
#[derive(Debug, Clone, Default)]
pub struct XmlAdapter;

impl XmlAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Extrait le contenu texte à l'intérieur d'une balise XML simple
    fn extract_tag_value(block: &str, tag_name: &str) -> Option<String> {
        let open_tag = format!("<{tag_name}");
        let close_tag = format!("</{tag_name}>");

        let start_pos = block.find(&open_tag)?;
        let rest = &block[start_pos..];
        let tag_end_pos = rest.find('>')?;
        let content_start = start_pos + tag_end_pos + 1;

        let end_pos = block[content_start..].find(&close_tag)?;
        let value = &block[content_start..content_start + end_pos];
        
        let trimmed = value.trim();
        if trimmed.is_empty() {
            None
        } else {
            // Nettoyage éventuel CDATA
            let cleaned = if trimmed.starts_with("<![CDATA[") && trimmed.ends_with("]]>") {
                &trimmed[9..trimmed.len() - 3]
            } else {
                trimmed
            };
            Some(cleaned.trim().to_string())
        }
    }

    /// Découpe un flux XML en blocs d'articles `<ARTICLE>...</ARTICLE>`, `<PRODUCT>...</PRODUCT>` ou `<ITEM>...</ITEM>`
    fn extract_article_blocks<'a>(content: &'a str) -> Vec<(&'a str, &'static str)> {
        let tag_candidates = ["ARTICLE", "PRODUCT", "ITEM", "article", "product", "item"];
        for tag in tag_candidates {
            let open = format!("<{tag}");
            let close = format!("</{tag}>");
            if content.contains(&open) && content.contains(&close) {
                let mut blocks = Vec::new();
                let mut cursor = 0;
                while let Some(start) = content[cursor..].find(&open) {
                    let abs_start = cursor + start;
                    if let Some(end) = content[abs_start..].find(&close) {
                        let abs_end = abs_start + end + close.len();
                        blocks.push((&content[abs_start..abs_end], tag));
                        cursor = abs_end;
                    } else {
                        break;
                    }
                }
                if !blocks.is_empty() {
                    return blocks;
                }
            }
        }
        Vec::new()
    }
}

#[async_trait]
impl SourceAdapter for XmlAdapter {
    fn format(&self) -> SourceFormat {
        SourceFormat::Xml
    }

    fn supported_versions(&self) -> &'static [&'static str] {
        &["BMECAT 1.2", "BMECAT 2005", "XML-CATALOG-GENERIC"]
    }

    fn validate_header(&self, sample: &[u8]) -> Result<(), IngestionError> {
        let text = std::str::from_utf8(sample).map_err(|e| {
            IngestionError::Validation(format!("Encodage XML invalide (UTF-8 requis) : {e}"))
        })?;

        let sample_upper = text.to_uppercase();
        let is_xml = sample_upper.contains("<?XML")
            || sample_upper.contains("<BMECAT")
            || sample_upper.contains("<CATALOG")
            || sample_upper.contains("<ARTICLES")
            || sample_upper.contains("<PRODUCTS");

        if !is_xml {
            return Err(IngestionError::Validation(
                "Le fichier n'est pas un document XML ou BMEcat valide".to_string(),
            ));
        }

        Ok(())
    }

    fn parse_content(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError> {
        let blocks = Self::extract_article_blocks(content);
        if blocks.is_empty() {
            return Ok(Vec::new());
        }

        let mut records = Vec::new();

        for (idx, (block, _tag_name)) in blocks.into_iter().enumerate() {
            let line_num = idx + 1;

            // Référence produit
            let reference = Self::extract_tag_value(block, "SUPPLIER_AID")
                .or_else(|| Self::extract_tag_value(block, "supplier_aid"))
                .or_else(|| Self::extract_tag_value(block, "REF_FAB"))
                .or_else(|| Self::extract_tag_value(block, "REFERENCE"))
                .or_else(|| Self::extract_tag_value(block, "SKU"))
                .unwrap_or_else(|| format!("XML_ART_{line_num}"));

            // Désignation
            let designation = Self::extract_tag_value(block, "DESCRIPTION_SHORT")
                .or_else(|| Self::extract_tag_value(block, "DESCRIPTION"))
                .or_else(|| Self::extract_tag_value(block, "LIBELLE"))
                .or_else(|| Self::extract_tag_value(block, "NAME"))
                .unwrap_or_else(|| format!("Article XML {reference}"));

            // GTIN / EAN
            let gtin = Self::extract_tag_value(block, "INTERNATIONAL_AID")
                .or_else(|| Self::extract_tag_value(block, "EAN"))
                .or_else(|| Self::extract_tag_value(block, "GTIN"));

            // Fabricant et marque
            let manufacturer = Self::extract_tag_value(block, "MANUFACTURER_NAME")
                .or_else(|| Self::extract_tag_value(block, "FABRICANT"));
            let brand = Self::extract_tag_value(block, "BRAND")
                .or_else(|| Self::extract_tag_value(block, "MARQUE"));

            // Unité de commande
            let unit = Self::extract_tag_value(block, "ORDER_UNIT")
                .or_else(|| Self::extract_tag_value(block, "UNITE"));

            // Prix
            let price = Self::extract_tag_value(block, "PRICE_AMOUNT")
                .or_else(|| Self::extract_tag_value(block, "PRIX"))
                .and_then(|p| p.replace(',', ".").parse::<f64>().ok());

            // Devise
            let currency = Self::extract_tag_value(block, "PRICE_CURRENCY")
                .or_else(|| Self::extract_tag_value(block, "CURRENCY"))
                .or_else(|| Some("EUR".to_string()));

            // Extraction attributs techniques simples
            let mut raw_attrs = HashMap::new();
            if let Some(etim) = Self::extract_tag_value(block, "REFERENCE_FEATURE_GROUP_ID") {
                raw_attrs.insert("etim_class".to_string(), etim);
            }
            if let Some(norm) = Self::extract_tag_value(block, "STANDARD") {
                raw_attrs.insert("norme".to_string(), norm);
            }

            // Dimensions si présentes
            let length = Self::extract_tag_value(block, "LENGTH").and_then(|v| v.parse::<f64>().ok());
            let width = Self::extract_tag_value(block, "WIDTH").and_then(|v| v.parse::<f64>().ok());
            let height = Self::extract_tag_value(block, "HEIGHT").and_then(|v| v.parse::<f64>().ok());
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
            let net_weight = Self::extract_tag_value(block, "WEIGHT").and_then(|v| v.parse::<f64>().ok());
            let weight = if net_weight.is_some() {
                Some(RawWeightDto {
                    net_weight,
                    gross_weight: None,
                    unit: Some("kg".to_string()),
                })
            } else {
                None
            };

            let raw_hash = lyxal_crypto::blake3_hex(block.as_bytes());
            let payload = json!({
                "format": "XML_BMECAT",
                "line": line_num,
                "block_xml": block,
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
        let records = adapter.parse_content(xml_content).unwrap();

        assert_eq!(records.len(), 1);
        assert_eq!(records[0].raw_reference, "BA13-PREGYPLAC");
        assert_eq!(records[0].raw_designation, "Plaque Siniat Pregyplac BA13 2500x1200");
        assert_eq!(records[0].raw_gtin, Some("3456789012399".to_string()));
        assert_eq!(records[0].raw_manufacturer, Some("SINIAT".to_string()));
        assert_eq!(records[0].raw_unit, Some("M2".to_string()));
        assert_eq!(records[0].raw_price, Some(8.20));
    }
}
