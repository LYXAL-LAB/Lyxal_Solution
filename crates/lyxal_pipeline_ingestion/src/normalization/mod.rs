//! Moteur de normalisation universel des catalogues fabricants Lyxal OS.
//!
//! Assure le nettoyage canonique, la conversion SI, le rapprochement `base_unite`
//! et l'évaluation initiale de la qualification commerciale (`VERIFIED`, `TO_CONFIRM`, `REJECTED`).

pub mod dimensions;
pub mod gtin;
pub mod manufacturer;
pub mod technical_attributes;
pub mod units;

pub use dimensions::{normalize_dimensions, normalize_weight, CanonicalDimensions, CanonicalWeight};
pub use gtin::{validate_and_normalize_gtin, GtinValidationError};
pub use manufacturer::normalize_manufacturer;
pub use technical_attributes::{normalize_technical_attributes, CanonicalTechnicalAttributes};
pub use units::normalize_unit;

use serde::{Deserialize, Serialize};
use serde_json::json;
use std::collections::HashMap;

use crate::adapters::RawRecordDto;
use crate::types::{ItemQualification, SourceFormat};

/// Article normalisé prêt pour le staging et le rapprochement technique.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct NormalizedItemDto {
    /// Numéro de ligne d'origine
    pub line_number: usize,
    /// Format de source d'origine
    pub source_format: SourceFormat,
    /// Référence fabricant normalisée
    pub manufacturer_ref: String,
    /// Fabricant normalisé canonique
    pub manufacturer: String,
    /// Marque commerciale normalisée
    pub brand: Option<String>,
    /// Libellé commercial propre
    pub commercial_label: String,
    /// Code GTIN validé (None si absent ou invalide)
    pub gtin: Option<String>,
    /// Statut de validité du GTIN
    pub is_gtin_valid: bool,
    /// Unité de mesure officielle `base_unite` (None si non résolue)
    pub unit_code: Option<String>,
    /// Prix tarif normalisé
    pub price: Option<f64>,
    /// Devise canonique (ex: "EUR")
    pub currency: String,
    /// Dimensions normalisées en mm
    pub dimensions: Option<CanonicalDimensions>,
    /// Poids normalisé en kg
    pub weight: Option<CanonicalWeight>,
    /// Caractéristiques techniques structurées
    pub technical_features: HashMap<String, String>,
    /// Preuve commerciale formelle traçable (Directive CTO Phase 4)
    pub commercial_proof: Option<crate::proof::CommercialProof>,
    /// Statut initial de qualification commerciale (VERIFIED, TO_CONFIRM, REJECTED)
    pub qualification: ItemQualification,
    /// Raison de la qualification attribuée
    pub qualification_reason: String,
    /// Empreinte canonique BLAKE3 du contenu normalisé
    pub canonical_fingerprint: String,
    /// Conservation immuable du payload brut d'origine
    pub raw_payload: serde_json::Value,
    /// Hachage BLAKE3 de la ligne brute
    pub raw_hash: String,
    /// Version du moteur de normalisation
    pub rules_engine_version: String,
}

/// Moteur de normalisation
#[derive(Debug, Clone)]
pub struct NormalizationEngine {
    rules_version: String,
    custom_unit_aliases: HashMap<String, String>,
    custom_mfg_aliases: HashMap<String, String>,
}

impl NormalizationEngine {
    pub fn new() -> Self {
        Self {
            rules_version: "2026.1".to_string(),
            custom_unit_aliases: HashMap::new(),
            custom_mfg_aliases: HashMap::new(),
        }
    }

    pub fn with_version(version: &str) -> Self {
        Self {
            rules_version: version.to_string(),
            custom_unit_aliases: HashMap::new(),
            custom_mfg_aliases: HashMap::new(),
        }
    }

    /// Enregistre un alias d'unité dynamique vers base_unite
    pub fn register_unit_alias(&mut self, raw: &str, canonical: &str) {
        self.custom_unit_aliases.insert(raw.trim().to_uppercase(), canonical.trim().to_uppercase());
    }

    /// Enregistre un alias de fabricant dynamique
    pub fn register_manufacturer_alias(&mut self, raw: &str, canonical: &str) {
        self.custom_mfg_aliases.insert(raw.trim().to_uppercase(), canonical.trim().to_uppercase());
    }

    /// Résout une unité brute via les alias dynamiques puis le référentiel statique
    pub fn resolve_unit(&self, raw: &str) -> Option<String> {
        let trimmed = raw.trim().to_uppercase();
        if let Some(canonical) = self.custom_unit_aliases.get(&trimmed) {
            return Some(canonical.clone());
        }
        normalize_unit(raw).map(|u| u.to_string())
    }

    /// Résout un fabricant brut via les alias dynamiques puis la normalisation statique
    pub fn resolve_manufacturer(&self, raw: &str) -> String {
        let trimmed = raw.trim().to_uppercase();
        if let Some(canonical) = self.custom_mfg_aliases.get(&trimmed) {
            return canonical.clone();
        }
        normalize_manufacturer(raw)
    }

    /// Normalise un enregistrement brut sans preuve commerciale (oriente en TO_CONFIRM si cohérent)
    pub fn normalize(
        &self,
        raw: &RawRecordDto,
        default_manufacturer: Option<&str>,
        source_format: SourceFormat,
    ) -> NormalizedItemDto {
        self.normalize_with_proof(raw, default_manufacturer, source_format, None)
    }

    /// Normalise un enregistrement brut avec preuve commerciale formelle (Directive CTO Phase 4)
    pub fn normalize_with_proof(
        &self,
        raw: &RawRecordDto,
        default_manufacturer: Option<&str>,
        source_format: SourceFormat,
        commercial_proof: Option<crate::proof::CommercialProof>,
    ) -> NormalizedItemDto {
        // 1. Normalisation référence
        let raw_ref = raw.raw_reference.trim();
        let clean_ref = if raw_ref.is_empty() {
            format!("AUTO_REF_{}", raw.line_number)
        } else {
            raw_ref.to_string()
        };

        // 2. Normalisation fabricant
        let mfg_input = raw.raw_manufacturer.as_deref()
            .or(raw.raw_brand.as_deref())
            .or(default_manufacturer)
            .unwrap_or("FABRICANT_NON_SPECIFIE");
        let clean_manufacturer = self.resolve_manufacturer(mfg_input);

        // 3. Normalisation marque
        let clean_brand = raw.raw_brand.as_deref().map(|b| self.resolve_manufacturer(b));

        // 4. Normalisation libellé commercial
        let clean_label = raw.raw_designation.trim().to_string();

        // 5. Validation et normalisation GTIN
        let mut clean_gtin = None;
        let mut is_gtin_valid = false;
        let mut gtin_error = None;

        if let Some(ref g) = raw.raw_gtin {
            match validate_and_normalize_gtin(g) {
                Ok(norm_gtin) => {
                    clean_gtin = Some(norm_gtin);
                    is_gtin_valid = true;
                }
                Err(err) => {
                    gtin_error = Some(err.to_string());
                }
            }
        }

        // 6. Normalisation unité vers `base_unite`
        let clean_unit = raw.raw_unit.as_deref().and_then(|u| self.resolve_unit(u));

        // 7. Normalisation dimensions et poids (depuis champs structurés ou texte)
        let (text_dims, text_weight) = dimensions::extract_specs_from_text(&clean_label);
        let mut clean_dims = normalize_dimensions(raw.raw_dimensions.as_ref());
        if clean_dims.is_none() {
            clean_dims = text_dims;
        }

        let mut clean_weight = normalize_weight(raw.raw_weight.as_ref());
        if clean_weight.is_none() {
            clean_weight = text_weight;
        }

        // 8. Normalisation caractéristiques techniques
        let tech_attrs = normalize_technical_attributes(&raw.raw_attributes, &clean_label);

        // 9. Évaluation stricte de la qualification (Directive CTO Phase 4)
        let (qualification, qualification_reason) = self.evaluate_qualification(
            &clean_ref,
            &clean_manufacturer,
            &clean_label,
            is_gtin_valid,
            gtin_error.as_deref(),
            clean_unit.is_some(),
            raw.raw_price,
            &clean_dims,
            &commercial_proof,
        );

        // 10. Calcul de l'empreinte canonique BLAKE3 du contenu normalisé
        let canonical_repr = json!({
            "manufacturer": clean_manufacturer,
            "reference": clean_ref,
            "label": clean_label,
            "gtin": clean_gtin,
            "unit": clean_unit,
            "dimensions": clean_dims,
            "weight": clean_weight,
            "features": tech_attrs.normalized_features,
            "proof": commercial_proof,
            "rules_version": self.rules_version,
        });

        let canonical_fingerprint = lyxal_crypto::blake3_hex(
            serde_json::to_string(&canonical_repr).unwrap_or_default().as_bytes()
        );

        NormalizedItemDto {
            line_number: raw.line_number,
            source_format,
            manufacturer_ref: clean_ref,
            manufacturer: clean_manufacturer,
            brand: clean_brand,
            commercial_label: clean_label,
            gtin: clean_gtin,
            is_gtin_valid,
            unit_code: clean_unit,
            price: raw.raw_price,
            currency: raw.raw_currency.clone().unwrap_or_else(|| "EUR".to_string()),
            dimensions: clean_dims,
            weight: clean_weight,
            technical_features: tech_attrs.normalized_features,
            commercial_proof,
            qualification,
            qualification_reason,
            canonical_fingerprint,
            raw_payload: raw.raw_payload.clone(),
            raw_hash: raw.raw_hash.clone(),
            rules_engine_version: self.rules_version.clone(),
        }
    }

    /// Applique les règles de qualification commerciale CTO (Phase 4)
    #[allow(clippy::too_many_arguments)]
    fn evaluate_qualification(
        &self,
        reference: &str,
        manufacturer: &str,
        designation: &str,
        is_gtin_valid: bool,
        gtin_error: Option<&str>,
        is_unit_resolved: bool,
        price: Option<f64>,
        dimensions: &Option<CanonicalDimensions>,
        commercial_proof: &Option<crate::proof::CommercialProof>,
    ) -> (ItemQualification, String) {
        // 1. Cas REJECTED : données manifestement invalides ou corrompues
        if reference.is_empty() || reference.starts_with("AUTO_REF_") {
            return (
                ItemQualification::Rejected,
                "Référence fabricant absente ou non renseignée".to_string(),
            );
        }

        if let Some(err) = gtin_error {
            return (
                ItemQualification::Rejected,
                format!("Code GTIN fourni invalide : {err}"),
            );
        }

        if let Some(p) = price {
            if p < 0.0 {
                return (
                    ItemQualification::Rejected,
                    "Prix unitaire négatif incohérent".to_string(),
                );
            }
        }

        // 2. Cas VERIFIED : REQUIERT STRICTEMENT UNE PREUVE COMMERCIALE FORMELLE ET AUDITABLE (Directive CTO Phase 4)
        // La simple conjonction GTIN + cotes + prix + fabricant ne prouve que la cohérence technique, jamais la provenance commerciale !
        let is_mfg_known = manufacturer != "FABRICANT_NON_SPECIFIE"
            && !manufacturer.is_empty()
            && !manufacturer.contains("(INDETERMINE)");
        let has_detailed_designation = designation.len() >= 8 && !designation.contains("Article sans libellé");
        let has_tech_coherence = price.is_some() || is_gtin_valid || dimensions.is_some();
        let has_valid_proof = commercial_proof.as_ref().map(|p| p.is_valid()).unwrap_or(false);

        if is_mfg_known && is_unit_resolved && has_detailed_designation && has_tech_coherence && has_valid_proof {
            let p = commercial_proof.as_ref().unwrap();
            return (
                ItemQualification::Verified,
                format!(
                    "Provenance commerciale formellement authentifiée ({:?} : {}) et conformité technique",
                    p.proof_type, p.proof_reference
                ),
            );
        }

        // 3. Cas TO_CONFIRM : cohérence démontrée mais preuve commerciale formelle absente ou incomplète
        let mut missing_items = Vec::new();
        if !has_valid_proof {
            missing_items.push("preuve commerciale formelle absente (source fabricant certifiée ou validation steward requise)");
        }
        if !is_mfg_known {
            missing_items.push("fabricant non vérifié");
        }
        if !is_unit_resolved {
            missing_items.push("unité non convertible en base_unite");
        }
        if !has_detailed_designation {
            missing_items.push("désignation commerciale trop succincte");
        }

        (
            ItemQualification::ToConfirm,
            format!("Maintien en TO_CONFIRM : {}", missing_items.join(", ")),
        )
    }
}

impl Default for NormalizationEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::adapters::RawRecordDto;

    #[test]
    fn test_normalization_and_qualification_verified() {
        let raw = RawRecordDto {
            line_number: 1,
            raw_reference: "BA13_2500".to_string(),
            raw_designation: "Placoplatre BA13 2500x1200".to_string(),
            raw_gtin: Some("3017620422003".to_string()),
            raw_manufacturer: Some("Saint-Gobain Placo SAS".to_string()),
            raw_brand: Some("PLACO".to_string()),
            raw_unit: Some("m2".to_string()),
            raw_price: Some(8.50),
            raw_currency: Some("EUR".to_string()),
            raw_dimensions: None,
            raw_weight: None,
            raw_attributes: HashMap::new(),
            raw_payload: json!({}),
            raw_hash: "hash".to_string(),
        };

        let engine = NormalizationEngine::new();
        // 1. Sans preuve commerciale formelle -> Maintien strict en TO_CONFIRM (Directive CTO Phase 4)
        let norm_no_proof = engine.normalize(&raw, None, SourceFormat::FabDis);
        assert_eq!(norm_no_proof.qualification, ItemQualification::ToConfirm);
        assert!(norm_no_proof.qualification_reason.contains("preuve commerciale formelle absente"));

        // 2. Avec preuve commerciale formelle (flux EDI signé) -> VERIFIED
        let proof = crate::proof::CommercialProof::new(
            crate::proof::CommercialProofType::CertifiedManufacturerEdi,
            "EDI-BORD-2026-SG-01",
            "EDI_HUB_SAINT_GOBAIN",
            "system:edi_receiver",
            "2026-10-25T10:00:00Z",
        );
        let norm_verified = engine.normalize_with_proof(&raw, None, SourceFormat::FabDis, Some(proof));
        assert_eq!(norm_verified.manufacturer, "PLACO");
        assert_eq!(norm_verified.manufacturer_ref, "BA13_2500");
        assert_eq!(norm_verified.unit_code, Some("M2".to_string()));
        assert_eq!(norm_verified.qualification, ItemQualification::Verified);
        assert!(norm_verified.dimensions.is_some());
        assert_eq!(norm_verified.dimensions.as_ref().unwrap().length_mm, Some(2500.0));
    }

    #[test]
    fn test_gtin_valid_alone_does_not_grant_verified() {
        // GTIN valide mais pas d'unité résolue et désignation trop succincte -> TO_CONFIRM
        let raw = RawRecordDto {
            line_number: 2,
            raw_reference: "ART-99".to_string(),
            raw_designation: "Art".to_string(),
            raw_gtin: Some("3017620422003".to_string()),
            raw_manufacturer: None,
            raw_brand: None,
            raw_unit: Some("UNITE_INCONNUE".to_string()),
            raw_price: None,
            raw_currency: None,
            raw_dimensions: None,
            raw_weight: None,
            raw_attributes: HashMap::new(),
            raw_payload: json!({}),
            raw_hash: "hash".to_string(),
        };

        let engine = NormalizationEngine::new();
        let norm = engine.normalize(&raw, None, SourceFormat::Csv);

        // Strictement TO_CONFIRM selon la règle d'or du CTO !
        assert_eq!(norm.qualification, ItemQualification::ToConfirm);
    }
}
