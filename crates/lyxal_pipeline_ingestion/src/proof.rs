//! Modèle formel de preuve commerciale traçable (Directive CTO Phase 4).
//!
//! Exigence absolue :
//! Un GTIN valide, des cotes cohérentes, un prix positif et un fabricant reconnu démontrent
//! une cohérence technique et syntaxique, JAMAIS une provenance commerciale authentifiée.
//!
//! Pour être qualifié VERIFIED, un article DOIT comporter une preuve commerciale formelle,
//! fiable, identifiable et auditable. Sans cette preuve, l'article est obligatoirement TO_CONFIRM.

use serde::{Deserialize, Serialize};

/// Type de preuve formelle attestant de la provenance commerciale d'une référence.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum CommercialProofType {
    /// Flux EDI officiel signé électroniquement par le fabricant (ex: GS1 XML / AS2 certifié)
    CertifiedManufacturerEdi,
    /// Bordereau tarifaire officiel ou catalogue dématérialisé avec signature fournisseur vérifiée
    SignedVendorCatalog,
    /// Certificat officiel de tarif fabricant avec horodatage certifié
    OfficialTariffCertificate,
    /// Validation humaine documentée par un Data Steward habilité (`steward_admin`)
    StewardDocumentedValidation,
}

impl std::fmt::Display for CommercialProofType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::CertifiedManufacturerEdi => write!(f, "CERTIFIED_MANUFACTURER_EDI"),
            Self::SignedVendorCatalog => write!(f, "SIGNED_VENDOR_CATALOG"),
            Self::OfficialTariffCertificate => write!(f, "OFFICIAL_TARIFF_CERTIFICATE"),
            Self::StewardDocumentedValidation => write!(f, "STEWARD_DOCUMENTED_VALIDATION"),
        }
    }
}

/// Preuve commerciale formelle, fiable et traçable attachée à un article ou lot.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CommercialProof {
    /// Type de preuve formelle
    pub proof_type: CommercialProofType,
    /// Référence traçable du document ou bordereau (ex: "EDI-BORD-2026-SG-0012")
    pub proof_reference: String,
    /// Autorité ou émetteur certifié (ex: "EDI_HUB_SAINT_GOBAIN", "PORTAIL_CERTIFIE_KNAUF")
    pub source_authority: String,
    /// Identité de l'agent ou de l'administrateur ayant audité ou scellé la preuve
    pub verified_by: String,
    /// Horodatage ISO-8601 de vérification ou d'émission
    pub verified_at: String,
}

impl CommercialProof {
    /// Crée une nouvelle preuve commerciale formelle
    pub fn new(
        proof_type: CommercialProofType,
        proof_reference: impl Into<String>,
        source_authority: impl Into<String>,
        verified_by: impl Into<String>,
        verified_at: impl Into<String>,
    ) -> Self {
        Self {
            proof_type,
            proof_reference: proof_reference.into(),
            source_authority: source_authority.into(),
            verified_by: verified_by.into(),
            verified_at: verified_at.into(),
        }
    }

    /// Validation synthétique d'intégrité de la preuve
    pub fn is_valid(&self) -> bool {
        !self.proof_reference.trim().is_empty()
            && !self.source_authority.trim().is_empty()
            && !self.verified_by.trim().is_empty()
            && !self.verified_at.trim().is_empty()
    }

    /// Détermine si la preuve est une preuve pilote, synthétique ou de banc d'essai (interdite pour la production réelle).
    pub fn is_pilot_or_synthetic(&self) -> bool {
        let pref = self.proof_reference.to_uppercase();
        let auth = self.source_authority.to_uppercase();
        let by = self.verified_by.to_uppercase();

        pref.starts_with("PROOF-AUTH-2026-")
            || pref.starts_with("PILOT-")
            || pref.starts_with("SYNTH-")
            || pref.contains("PILOT")
            || pref.contains("SYNTHETIC")
            || pref.contains("DEMO")
            || pref.contains("TEST-BENCH")
            || auth.contains("PILOT")
            || auth.contains("SYNTHETIC")
            || auth.contains("BANC D'ESSAI")
            || auth.contains("TEST")
            || by.contains("TEST")
    }

    /// Contrôle formel d'éligibilité pour une publication réelle en production :
    /// - La preuve doit être structurellement valide.
    /// - Toute preuve pilote, synthétique ou de banc d'essai est catégoriquement exclue.
    pub fn is_eligible_for_production(&self) -> bool {
        self.is_valid() && !self.is_pilot_or_synthetic()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_commercial_proof_validation() {
        let proof = CommercialProof::new(
            CommercialProofType::CertifiedManufacturerEdi,
            "EDI-2026-PLACO-001",
            "EDI_HUB_SAINT_GOBAIN",
            "system:edi_receiver",
            "2026-10-25T10:00:00Z",
        );
        assert!(proof.is_valid());
        assert_eq!(proof.proof_type, CommercialProofType::CertifiedManufacturerEdi);
        assert!(!proof.is_pilot_or_synthetic());
        assert!(proof.is_eligible_for_production());

        let invalid_proof = CommercialProof::new(
            CommercialProofType::SignedVendorCatalog,
            "",
            "SOURCE",
            "USER",
            "2026-10-25",
        );
        assert!(!invalid_proof.is_valid());
        assert!(!invalid_proof.is_eligible_for_production());
    }

    #[test]
    fn test_pilot_and_synthetic_proofs_ineligible_for_production() {
        // Preuve pilote Placo (jeton de validation technique)
        let pilot_proof = CommercialProof::new(
            CommercialProofType::CertifiedManufacturerEdi,
            "PROOF-AUTH-2026-P01302500",
            "SAINT-GOBAIN PLACO Direction Commerciale Officielle",
            "steward_admin_btp",
            "2026-10-25T14:00:00Z",
        );
        assert!(pilot_proof.is_valid());
        assert!(pilot_proof.is_pilot_or_synthetic(), "Les jetons PROOF-AUTH-2026-* doivent être détectés comme pilotes");
        assert!(!pilot_proof.is_eligible_for_production(), "Une preuve pilote ne doit JAMAIS être éligible à la production");

        // Preuve synthétique de banc d'essai
        let synth_proof = CommercialProof::new(
            CommercialProofType::StewardDocumentedValidation,
            "SYNTHETIC-TEST-BENCH-PROOF-01",
            "Banc d'Essai Technique Interne Lyxal",
            "test_runner",
            "2026-10-25T14:00:00Z",
        );
        assert!(synth_proof.is_valid());
        assert!(synth_proof.is_pilot_or_synthetic(), "Une preuve synthétique doit être détectée");
        assert!(!synth_proof.is_eligible_for_production(), "Une preuve synthétique ne doit JAMAIS être éligible à la production");
    }
}
