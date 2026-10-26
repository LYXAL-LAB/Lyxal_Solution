//! Types formels pour la gestion de la quarantaine et la classification des anomalies (Directive CTO Phase 3).

use serde::{Deserialize, Serialize};
use crate::types::{ItemQualification, StateTransitionRecord};

/// Sévérité de l'anomalie détectée lors de l'ingestion ou de la normalisation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum AnomalySeverity {
    /// Information informative (n'empêche pas la publication)
    Info = 1,
    /// Avertissement (nécessite validation TO_CONFIRM)
    Warning = 2,
    /// Erreur bloquante (article rejeté REJECTED)
    Error = 3,
    /// Anomalie fatale (corruption de structure ou falsification de lot)
    Fatal = 4,
}

impl std::fmt::Display for AnomalySeverity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Info => write!(f, "INFO"),
            Self::Warning => write!(f, "WARNING"),
            Self::Error => write!(f, "ERROR"),
            Self::Fatal => write!(f, "FATAL"),
        }
    }
}

/// Catégories normalisées d'anomalies de catalogue BTP.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum AnomalyCategory {
    /// Structure de données corrompue ou syntaxe illisible
    MalformedData,
    /// Code GTIN-13 avec somme de contrôle GS1 Modulo 10 erronée
    InvalidGtin,
    /// Unité de mesure fournisseur non résolue dans `base_unite`
    UnresolvedUnit,
    /// Preuve commerciale insuffisante (absence de tarif, désignation creuse)
    MissingCommercialProof,
    /// Incohérence dimensionnelle ou pondérale (cotes négatives ou aberrantes)
    IncoherentDimensions,
    /// Référence fabricant ambiguë, vide ou collisionnée
    AmbiguousReference,
    /// Tentative de substitution contractuelle non justifiée ou révoquée
    UnverifiedSubstitution,
    /// Confusion ou assimilation erronée de filiales au sein d'un même groupe
    EntityMismatch,
    /// Incompatibilité avec le système constructif spécifié
    SystemIncompatibility,
}

/// Statut de cycle de vie d'une entrée mise en quarantaine.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum QuarantineStatus {
    /// En quarantaine active (en attente de révision ou arbitrage)
    Quarantined,
    /// Requalifié par un steward_admin avec justification
    Requalified,
    /// Rejet confirmé et classé sans suite
    Dismissed,
}

/// Entrée d'audit détaillée enregistrée en zone de quarantaine (`ingestion_quarantine_record`).
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct QuarantineEntry {
    /// Identifiant unique de l'anomalie
    pub entry_id: String,
    /// Identifiant du lot d'origine
    pub batch_id: String,
    /// Numéro de ligne d'origine (1-indexé)
    pub line_number: usize,
    /// Hachage BLAKE3 de la ligne brute
    pub raw_hash: String,
    /// Référence fabricant concernée si disponible
    pub manufacturer_ref: Option<String>,
    /// Fabricant déclaré
    pub manufacturer: Option<String>,
    /// Sévérité de l'anomalie
    pub severity: AnomalySeverity,
    /// Catégorie normalisée
    pub category: AnomalyCategory,
    /// Code d'erreur officiel (ex: "INGESTION_GTIN_INVALID")
    pub code: String,
    /// Motif explicite rédigé et auditable
    pub message: String,
    /// Champ fautif identifié
    pub field_name: Option<String>,
    /// Valeur fautive brute
    pub faulty_value: Option<String>,
    /// Payload brut d'origine intégral pour audit
    pub raw_payload: serde_json::Value,
    /// Statut actuel de l'anomalie
    pub status: QuarantineStatus,
    /// Qualification résultante de l'article (ex: REJECTED ou TO_CONFIRM)
    pub resulting_qualification: ItemQualification,
    /// Historique des révisions et requalifications
    pub audit_trail: Vec<StateTransitionRecord>,
    /// Horodatage de création
    pub created_at: String,
}

/// Statistiques agrégées des anomalies pour un lot d'ingestion.
#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq)]
pub struct QuarantineStats {
    pub total_anomalies: usize,
    pub fatal_count: usize,
    pub error_count: usize,
    pub warning_count: usize,
    pub info_count: usize,
    pub requalified_count: usize,
}
