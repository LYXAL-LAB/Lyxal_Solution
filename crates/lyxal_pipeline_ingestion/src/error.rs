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

    #[error("Référence fabricant obligatoire manquante ou vide pour le fabricant '{fabricant}'.")]
    MissingManufacturerRef { fabricant: String },

    #[error(
        "Unité fournisseur '{unite}' non convertible ou inconnue dans le référentiel 'base_unite'."
    )]
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

    #[error("Erreur de stockage ou d'accès aux données : {0}")]
    Storage(String),

    /// Erreur d'une fonction SurrealQL du module : erreur métier (`fn::error_result`, code
    /// `INGESTION_*` conservé) ou erreur de transport. En boîte : `LyxalSurrealError` est
    /// volumineuse et alourdirait chaque `IngestionResult`.
    #[error("{0}")]
    Surreal(Box<lyxal_surreal::LyxalSurrealError>),
}

impl From<lyxal_surreal::LyxalSurrealError> for IngestionError {
    fn from(err: lyxal_surreal::LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(err))
    }
}

/// Référence d'un code d'erreur du pipeline, identique à sa définition dans `error/<thème>/`
/// (un test vérifie la correspondance).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct IngestionErrorInfo {
    pub code: &'static str,
    pub category: &'static str,
    pub http_status: u16,
    pub retryable: bool,
}

const fn info(
    code: &'static str,
    category: &'static str,
    http_status: u16,
    retryable: bool,
) -> IngestionErrorInfo {
    IngestionErrorInfo {
        code,
        category,
        http_status,
        retryable,
    }
}

impl IngestionError {
    /// Code, catégorie, statut HTTP et caractère réessayable de l'erreur.
    pub fn info(&self) -> IngestionErrorInfo {
        match self {
            Self::InvalidSourceFormat(_) => {
                info("INGESTION_SOURCE_INVALID", "validation", 400, false)
            }
            Self::Validation(_) => info("INGESTION_VALIDATION_ERROR", "validation", 400, false),
            Self::Adapter(_) => info("INGESTION_ADAPTER_ERROR", "validation", 400, false),
            Self::DuplicateBatch { .. } => {
                info("INGESTION_BATCH_DUPLICATE", "conflict", 409, false)
            }
            Self::MissingManufacturerRef { .. } => info(
                "INGESTION_MANUFACTURER_REF_MISSING",
                "validation",
                400,
                false,
            ),
            Self::UnresolvedBaseUnit { .. } => {
                info("INGESTION_UNIT_UNRESOLVED", "validation", 422, false)
            }
            Self::IncoherentPackaging { .. } => {
                info("INGESTION_PACKAGING_INCOHERENT", "validation", 422, false)
            }
            Self::IllegalStateTransition { .. } | Self::IllegalTransition(_) => {
                info("INGESTION_ILLEGAL_STATE_TRANSITION", "conflict", 409, false)
            }
            Self::SealVerificationFailed { .. } => {
                info("INGESTION_SEAL_VERIFICATION_FAILED", "conflict", 409, false)
            }
            Self::FingerprintTampered(_) => {
                info("INGESTION_FINGERPRINT_TAMPERED", "conflict", 409, false)
            }
            Self::Unauthorized(_) => info("INGESTION_UNAUTHORIZED", "authorization", 403, false),
            Self::Storage(_) => info("INGESTION_STORAGE_ERROR", "dependency", 503, true),
            // Erreur métier ou contrat de réponse non respecté (une erreur métier garde son
            // propre code, transmis tel quel par la conversion en `LyxalError`).
            Self::Surreal(err) => match err.as_ref() {
                lyxal_surreal::LyxalSurrealError::Call(_) => {
                    info("INGESTION_CALL_ERROR", "internal", 500, false)
                }
                _ => info("INGESTION_DB_ERROR", "dependency", 503, true),
            },
        }
    }
}

impl IngestionError {
    /// Code de l'erreur : celui de l'erreur métier SurrealQL, sinon celui de [`Self::info`].
    pub fn code(&self) -> String {
        if let Self::Surreal(err) = self {
            if let lyxal_surreal::LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(
                business,
            )) = err.as_ref()
            {
                return business.code.clone();
            }
        }
        self.info().code.to_string()
    }

    /// Indique si l'erreur est l'erreur métier SurrealQL `code`.
    pub fn is_business_code(&self, code: &str) -> bool {
        matches!(self, Self::Surreal(err) if matches!(err.as_ref(), lyxal_surreal::LyxalSurrealError::Call(call) if call.is_business_code(code)))
    }
}

impl From<IngestionError> for LyxalError {
    fn from(err: IngestionError) -> Self {
        // Une erreur métier est déjà résolue par lyxal_error : elle est transmise telle quelle.
        let err = match err {
            IngestionError::Surreal(surreal) => match *surreal {
                lyxal_surreal::LyxalSurrealError::Call(lyxal_error::LyxalCallError::Business(
                    business,
                )) => return business,
                other => IngestionError::from(other),
            },
            other => other,
        };
        let info = err.info();
        LyxalError {
            code: info.code.to_string(),
            message: err.to_string(),
            label: info.code.to_string(),
            description: Some(err.to_string()),
            resolution: None,
            category: info.category.to_string(),
            severity: if info.category == "internal" {
                "critical"
            } else {
                "error"
            }
            .to_string(),
            http_status: Some(info.http_status),
            retryable: info.retryable,
            documentation: serde_json::json!({}),
            metadata: serde_json::json!({}),
            details: serde_json::json!({}),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Une valeur de chaque variante d'`IngestionError`.
    fn every_variant() -> Vec<IngestionError> {
        let text = || "détail".to_string();
        vec![
            IngestionError::InvalidSourceFormat(text()),
            IngestionError::Validation(text()),
            IngestionError::DuplicateBatch { hash: text() },
            IngestionError::MissingManufacturerRef { fabricant: text() },
            IngestionError::UnresolvedBaseUnit { unite: text() },
            IngestionError::IncoherentPackaging { details: text() },
            IngestionError::IllegalStateTransition {
                from: text(),
                to: text(),
            },
            IngestionError::SealVerificationFailed {
                manifest_id: text(),
            },
            IngestionError::Unauthorized(text()),
            IngestionError::Adapter(text()),
            IngestionError::IllegalTransition(text()),
            IngestionError::FingerprintTampered(text()),
            IngestionError::Storage(text()),
            IngestionError::from(lyxal_surreal::LyxalSurrealError::UnsupportedEndpoint {
                endpoint: text(),
            }),
            IngestionError::from(lyxal_surreal::LyxalSurrealError::Call(
                lyxal_error::LyxalCallError::InvalidContract {
                    function: "fn::test",
                },
            )),
        ]
    }

    /// Bloc de définition d'un code dans `error/<thème>/*.surql`.
    fn definition(code: &str) -> Option<String> {
        let dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("error");
        for theme in std::fs::read_dir(dir).ok()?.flatten() {
            for file in std::fs::read_dir(theme.path()).ok()?.flatten() {
                let text = std::fs::read_to_string(file.path()).ok()?;
                let marker = format!("CREATE error_definition:{code} CONTENT");
                if let Some(start) = text.find(&marker) {
                    let block = &text[start..];
                    let end = block.find(") END;").unwrap_or(block.len());
                    return Some(block[..end].to_string());
                }
            }
        }
        None
    }

    #[test]
    fn rust_codes_match_their_definitions() {
        for err in every_variant() {
            let info = err.info();
            let Some(block) = definition(info.code) else {
                panic!("{} : aucune définition dans error/", info.code);
            };
            for expected in [
                format!("category: \"{}\"", info.category),
                format!("http_status: {}", info.http_status),
                format!("retryable: {}", info.retryable),
            ] {
                assert!(
                    block.contains(&expected),
                    "{} : {expected} attendu dans sa définition",
                    info.code
                );
            }
        }
    }
}
