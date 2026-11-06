//! Moteur de normalisation universel des catalogues fabricants Lyxal OS.
//!
//! Assure le nettoyage canonique, la conversion SI et l'évaluation initiale de la qualification
//! commerciale (`VERIFIED`, `TO_CONFIRM`, `REJECTED`). Unités et fabricants sont résolus par les
//! référentiels en base, une fois par bloc (`IngestionStore::block_referentials`) ; le moteur
//! reçoit ces résolutions (`BlockReferentials`) et ne contient aucune table de correspondance.

pub mod dimensions;
pub mod technical_attributes;

pub use dimensions::{
    normalize_dimensions, normalize_weight, CanonicalDimensions, CanonicalWeight,
};
pub use technical_attributes::{normalize_technical_attributes, CanonicalTechnicalAttributes};

use lyxal_surreal::SurrealValue;
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
    /// Code-barres fourni (espaces retirés) ; sa clé GS1 est contrôlée par
    /// `fn::ingestion_staged_save` (`fn::validation_gtin` de lyxal_core).
    pub gtin: Option<String>,
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
    /// Preuve commerciale formelle traçable
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

/// Fabricant ou marque résolu par `fn::ingestion_resolve_manufacturers` (nom normalisé et
/// `resolved = false` si aucun alias ne le connaît).
#[derive(Deserialize, Serialize, Debug, Clone, PartialEq, SurrealValue)]
pub struct ResolvedManufacturer {
    pub canonical_name: String,
    pub holding_or_group: Option<String>,
    pub is_verified: bool,
    pub resolved: bool,
}

/// Résolutions d'un bloc de lignes, indexées par valeur brute sans espaces périphériques :
/// unités utilisables (`fn::ingestion_resolve_units`) et fabricants ou marques
/// (`fn::ingestion_resolve_manufacturers`).
#[derive(Debug, Clone, Default, PartialEq)]
pub struct BlockReferentials {
    pub units: HashMap<String, String>,
    pub manufacturers: HashMap<String, ResolvedManufacturer>,
}

impl BlockReferentials {
    /// Unités brutes et fabricants ou marques bruts distincts d'un bloc, à résoudre en base.
    pub fn raw_values(
        records: &[RawRecordDto],
        default_manufacturer: Option<&str>,
    ) -> (Vec<String>, Vec<String>) {
        let mut units = Vec::new();
        let mut names = Vec::new();
        let push = |list: &mut Vec<String>, value: Option<&str>| {
            if let Some(v) = value.map(str::trim).filter(|v| !v.is_empty()) {
                if !list.iter().any(|known| known == v) {
                    list.push(v.to_string());
                }
            }
        };
        for record in records {
            push(&mut units, record.raw_unit.as_deref());
            push(&mut names, record.raw_manufacturer.as_deref());
            push(&mut names, record.raw_brand.as_deref());
        }
        push(&mut names, default_manufacturer);
        (units, names)
    }

    fn unit(&self, raw: &str) -> Option<String> {
        self.units.get(raw.trim()).cloned()
    }

    /// Nom canonique et fabricant connu (renseigné et non signalé comme groupe sans entité
    /// déterminée). Un nom que le bloc n'a pas résolu reste tel quel, non connu.
    fn manufacturer(&self, raw: &str) -> (String, bool) {
        match self.manufacturers.get(raw.trim()) {
            Some(m) => (m.canonical_name.clone(), !(m.resolved && !m.is_verified)),
            None => (raw.trim().to_string(), false),
        }
    }
}

/// Fabricant retenu lorsqu'aucune source n'en indique.
const UNSPECIFIED_MANUFACTURER: &str = "FABRICANT_NON_SPECIFIE";

/// Moteur de normalisation
#[derive(Debug, Clone)]
pub struct NormalizationEngine {
    rules_version: String,
}

impl NormalizationEngine {
    pub fn new() -> Self {
        Self::with_version("2026.1")
    }

    pub fn with_version(version: &str) -> Self {
        Self {
            rules_version: version.to_string(),
        }
    }

    /// Normalise un enregistrement brut sans preuve commerciale (oriente en TO_CONFIRM si cohérent)
    pub fn normalize(
        &self,
        raw: &RawRecordDto,
        default_manufacturer: Option<&str>,
        source_format: SourceFormat,
        referentials: &BlockReferentials,
    ) -> NormalizedItemDto {
        self.normalize_with_proof(raw, default_manufacturer, source_format, None, referentials)
    }

    /// Normalise un enregistrement brut avec preuve commerciale formelle
    pub fn normalize_with_proof(
        &self,
        raw: &RawRecordDto,
        default_manufacturer: Option<&str>,
        source_format: SourceFormat,
        commercial_proof: Option<crate::proof::CommercialProof>,
        referentials: &BlockReferentials,
    ) -> NormalizedItemDto {
        // 1. Normalisation référence
        let raw_ref = raw.raw_reference.trim();
        let clean_ref = if raw_ref.is_empty() {
            format!("AUTO_REF_{}", raw.line_number)
        } else {
            raw_ref.to_string()
        };

        // 2. Normalisation fabricant
        let mfg_input = raw
            .raw_manufacturer
            .as_deref()
            .or(raw.raw_brand.as_deref())
            .or(default_manufacturer)
            .filter(|m| !m.trim().is_empty());
        let (clean_manufacturer, is_mfg_known) = match mfg_input {
            Some(name) => referentials.manufacturer(name),
            None => (UNSPECIFIED_MANUFACTURER.to_string(), false),
        };

        // 3. Normalisation marque
        let clean_brand = raw
            .raw_brand
            .as_deref()
            .filter(|b| !b.trim().is_empty())
            .map(|b| referentials.manufacturer(b).0);

        // 4. Normalisation libellé commercial
        let clean_label = raw.raw_designation.trim().to_string();

        // 5. Code-barres : transmis tel quel ; sa clé GS1 est contrôlée par SurrealQL
        let clean_gtin = raw
            .raw_gtin
            .as_deref()
            .map(str::trim)
            .filter(|g| !g.is_empty())
            .map(str::to_string);

        // 6. Unité résolue par le référentiel (None si inconnue : jamais de valeur par défaut)
        let clean_unit = raw.raw_unit.as_deref().and_then(|u| referentials.unit(u));

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

        // 9. Évaluation stricte de la qualification
        let (qualification, qualification_reason) = self.evaluate_qualification(
            &clean_ref,
            is_mfg_known,
            &clean_label,
            clean_gtin.is_some(),
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

        // `Value` s'affiche toujours en JSON : aucune erreur de sérialisation possible.
        let canonical_fingerprint = lyxal_crypto::blake3_hex(canonical_repr.to_string().as_bytes());

        NormalizedItemDto {
            line_number: raw.line_number,
            source_format,
            manufacturer_ref: clean_ref,
            manufacturer: clean_manufacturer,
            brand: clean_brand,
            commercial_label: clean_label,
            gtin: clean_gtin,
            unit_code: clean_unit,
            price: raw.raw_price,
            currency: raw
                .raw_currency
                .clone()
                .unwrap_or_else(|| "EUR".to_string()),
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

    /// Applique les règles de qualification commerciale CTO
    #[allow(clippy::too_many_arguments)]
    fn evaluate_qualification(
        &self,
        reference: &str,
        is_mfg_known: bool,
        designation: &str,
        has_gtin: bool,
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

        if let Some(p) = price {
            if p < 0.0 {
                return (
                    ItemQualification::Rejected,
                    "Prix unitaire négatif incohérent".to_string(),
                );
            }
        }

        // 2. Cas VERIFIED : REQUIERT STRICTEMENT UNE PREUVE COMMERCIALE FORMELLE ET AUDITABLE
        // La simple conjonction GTIN + cotes + prix + fabricant ne prouve que la cohérence technique, jamais la provenance commerciale !
        let has_detailed_designation =
            designation.len() >= 8 && !designation.contains("Article sans libellé");
        let has_tech_coherence = price.is_some() || has_gtin || dimensions.is_some();
        let valid_proof = commercial_proof.as_ref().filter(|p| p.is_valid());
        let has_valid_proof = valid_proof.is_some();

        if let Some(p) = valid_proof.filter(|_| {
            is_mfg_known && is_unit_resolved && has_detailed_designation && has_tech_coherence
        }) {
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

    /// Résolutions telles que les renvoient les référentiels en base pour ces lignes.
    fn referentials() -> BlockReferentials {
        let mut refs = BlockReferentials::default();
        refs.units.insert("m2".to_string(), "M2".to_string());
        for (raw, canonical) in [("Saint-Gobain Placo SAS", "PLACO"), ("PLACO", "PLACO")] {
            refs.manufacturers.insert(
                raw.to_string(),
                ResolvedManufacturer {
                    canonical_name: canonical.to_string(),
                    holding_or_group: Some("SAINT-GOBAIN".to_string()),
                    is_verified: true,
                    resolved: true,
                },
            );
        }
        refs
    }

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
        // 1. Sans preuve commerciale formelle -> Maintien strict en TO_CONFIRM
        let norm_no_proof = engine.normalize(&raw, None, SourceFormat::FabDis, &referentials());
        assert_eq!(norm_no_proof.qualification, ItemQualification::ToConfirm);
        assert!(norm_no_proof
            .qualification_reason
            .contains("preuve commerciale formelle absente"));

        // 2. Avec preuve commerciale formelle (flux EDI signé) -> VERIFIED
        let proof = crate::proof::CommercialProof::new(
            crate::proof::CommercialProofType::CertifiedManufacturerEdi,
            "EDI-BORD-2026-SG-01",
            "EDI_HUB_SAINT_GOBAIN",
            "system:edi_receiver",
            "2026-10-25T10:00:00Z",
        );
        let norm_verified = engine.normalize_with_proof(
            &raw,
            None,
            SourceFormat::FabDis,
            Some(proof),
            &referentials(),
        );
        assert_eq!(norm_verified.manufacturer, "PLACO");
        assert_eq!(norm_verified.manufacturer_ref, "BA13_2500");
        assert_eq!(norm_verified.unit_code, Some("M2".to_string()));
        assert_eq!(norm_verified.qualification, ItemQualification::Verified);
        assert!(norm_verified.dimensions.is_some());
        assert_eq!(
            norm_verified.dimensions.as_ref().unwrap().length_mm,
            Some(2500.0)
        );
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
        let norm = engine.normalize(&raw, None, SourceFormat::Csv, &referentials());

        // Strictement TO_CONFIRM selon la règle d'or du CTO ; unité inconnue : aucune valeur
        assert_eq!(norm.qualification, ItemQualification::ToConfirm);
        assert_eq!(norm.unit_code, None);
        assert_eq!(norm.manufacturer, UNSPECIFIED_MANUFACTURER);
    }

    #[test]
    fn raw_values_are_distinct_and_trimmed() {
        let mut line = RawRecordDto {
            line_number: 1,
            raw_reference: "R".to_string(),
            raw_designation: "D".to_string(),
            raw_gtin: None,
            raw_manufacturer: Some(" Placo ".to_string()),
            raw_brand: Some("PLACO".to_string()),
            raw_unit: Some(" m2 ".to_string()),
            raw_price: None,
            raw_currency: None,
            raw_dimensions: None,
            raw_weight: None,
            raw_attributes: HashMap::new(),
            raw_payload: json!({}),
            raw_hash: "hash".to_string(),
        };
        let second = line.clone();
        line.raw_unit = Some("m2".to_string());
        let (units, names) = BlockReferentials::raw_values(&[line, second], Some("KNAUF"));
        assert_eq!(units, vec!["m2".to_string()]);
        assert_eq!(
            names,
            vec![
                "Placo".to_string(),
                "PLACO".to_string(),
                "KNAUF".to_string()
            ]
        );
    }

    #[test]
    fn group_without_determined_entity_is_not_a_known_manufacturer() {
        let mut refs = BlockReferentials::default();
        refs.manufacturers.insert(
            "Saint Gobain".to_string(),
            ResolvedManufacturer {
                canonical_name: "SAINT-GOBAIN".to_string(),
                holding_or_group: Some("SAINT-GOBAIN".to_string()),
                is_verified: false,
                resolved: true,
            },
        );
        assert_eq!(
            refs.manufacturer("Saint Gobain"),
            ("SAINT-GOBAIN".to_string(), false)
        );
        assert_eq!(refs.manufacturer("Inconnu").1, false);
    }
}
