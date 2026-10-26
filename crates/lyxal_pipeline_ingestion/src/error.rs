use lyxal_error::LyxalError;
use thiserror::Error;

pub type IngestionResult<T> = Result<T, IngestionError>;

#[derive(Debug, Error)]
pub enum IngestionError {
    #[error("Format source invalide ou en-tête non reconnu : {0}")]
    InvalidSourceFormat(String),

    #[error("Erreur de validation ou de parsing : {0}")]
    Validation(String),

    #[error("Lot dupliqué détecté avec l'empreinte BLAKE3 '{hash}'.")]
    DuplicateBatch { hash: String },

    #[error("Code GTIN-13 '{gtin}' invalide (clé GS1 Modulo 10 incorrecte).")]
    InvalidGtin { gtin: String },

    #[error("Référence fabricant obligatoire manquante ou vide pour le fabricant '{fabricant}'.")]
    MissingManufacturerRef { fabricant: String },

    #[error("Unité fournisseur '{unite}' non convertible ou inconnue dans le référentiel 'base_unite'.")]
    UnresolvedBaseUnit { unite: String },

    #[error("Conditionnement physique incohérent : {details}")]
    IncoherentPackaging { details: String },

    #[error("Transition d'état illégale de '{from}' vers '{to}'.")]
    IllegalStateTransition { from: String, to: String },

    #[error("Rupture de scellement du manifeste '{manifest_id}' : les données en staging ont été altérées depuis l'approbation.")]
    SealVerificationFailed { manifest_id: String },

    #[error("Opération non autorisée pour l'identité ou le rôle spécifié : {0}")]
    Unauthorized(String),

    #[error("Erreur d'adaptateur de source : {0}")]
    Adapter(String),

    #[error("Transition d'état illégale : {0}")]
    IllegalTransition(String),

    #[error("Altération d'empreinte ou de scellement détectée : {0}")]
    FingerprintTampered(String),

    #[error("Erreur de persistance SurrealDB : {0}")]
    Database(String),

    #[error("Erreur de stockage ou d'accès aux données : {0}")]
    Storage(String),

    #[error("Erreur d'appel ou de contrat Lyxal : {0}")]
    LyxalCall(#[from] lyxal_error::LyxalCallError),
}

impl From<IngestionError> for LyxalError {
    fn from(err: IngestionError) -> Self {
        let (code, category, retryable) = match &err {
            IngestionError::InvalidSourceFormat(_) => ("INGESTION_SOURCE_INVALID", "validation", false),
            IngestionError::Validation(_) => ("INGESTION_VALIDATION_ERROR", "validation", false),
            IngestionError::Adapter(_) => ("INGESTION_ADAPTER_ERROR", "validation", false),
            IngestionError::DuplicateBatch { .. } => ("INGESTION_BATCH_DUPLICATE", "business", false),
            IngestionError::InvalidGtin { .. } => ("INGESTION_GTIN_INVALID", "validation", false),
            IngestionError::MissingManufacturerRef { .. } => ("INGESTION_MANUFACTURER_REF_MISSING", "validation", false),
            IngestionError::UnresolvedBaseUnit { .. } => ("INGESTION_UNIT_UNRESOLVED", "validation", false),
            IngestionError::IncoherentPackaging { .. } => ("INGESTION_PACKAGING_INCOHERENT", "validation", false),
            IngestionError::IllegalStateTransition { .. } => ("INGESTION_ILLEGAL_STATE_TRANSITION", "business", false),
            IngestionError::IllegalTransition(_) => ("INGESTION_ILLEGAL_STATE_TRANSITION", "business", false),
            IngestionError::SealVerificationFailed { .. } => ("INGESTION_SEAL_VERIFICATION_FAILED", "security", false),
            IngestionError::FingerprintTampered(_) => ("INGESTION_FINGERPRINT_TAMPERED", "security", false),
            IngestionError::Unauthorized(_) => ("INGESTION_UNAUTHORIZED", "security", false),
            IngestionError::Database(_) => ("INGESTION_DB_ERROR", "technical", true),
            IngestionError::Storage(_) => ("INGESTION_STORAGE_ERROR", "technical", true),
            IngestionError::LyxalCall(_) => ("INGESTION_CALL_ERROR", "technical", false),
        };

        LyxalError {
            code: code.to_string(),
            message: err.to_string(),
            label: code.to_string(),
            description: Some(err.to_string()),
            resolution: None,
            category: category.to_string(),
            severity: "error".to_string(),
            http_status: Some(400),
            retryable,
            documentation: serde_json::json!({}),
            metadata: serde_json::json!({}),
            details: serde_json::json!({}),
        }
    }
}
