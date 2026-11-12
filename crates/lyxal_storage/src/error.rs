//! Erreurs des services Rust de `lyxal_storage`. Les erreurs métier viennent des fonctions
//! SurrealQL (codes `STORAGE_*` de la master data), portées par `LyxalSurrealError`.

use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use thiserror::Error;

/// Erreur d'un service de `lyxal_storage`. Aucune variante ne contient de contenu de fichier.
#[derive(Debug, Error)]
pub enum StorageError {
    /// Échec d'une fonction SurrealQL (code `STORAGE_*`) ou du transport.
    #[error("{0}")]
    Surreal(Box<LyxalSurrealError>),
    /// Support non configuré sur ce serveur.
    #[error("support de stockage non configuré : {0}")]
    BackendUnknown(String),
    /// Support injoignable ou opération refusée par le support.
    #[error("support de stockage indisponible : {0}")]
    BackendUnavailable(String),
    /// Contenu reçu différent de l'annonce : taille, dépassement, flux interrompu.
    #[error("contenu différent de l'annonce : {0}")]
    ContentMismatch(String),
    /// Plage d'octets demandée hors du fichier ; porte la taille du fichier.
    #[error("plage d'octets hors du fichier ({0} octets)")]
    RangeNotSatisfiable(u64),
    /// Menace reconnue par l'antivirus dans le contenu envoyé ; porte le nom de la signature.
    #[error("fichier refusé par l'antivirus : {0}")]
    Infected(String),
    /// Antivirus configuré mais incapable d'analyser le contenu.
    #[error("antivirus indisponible : {0}")]
    ScannerUnavailable(String),
    /// Position annoncée différente de celle d'un envoi reprenable ; porte la position courante.
    #[error("position d'envoi incorrecte : l'envoi en est à {0} octets")]
    UploadOffsetMismatch(u64),
    /// Requête d'envoi reprenable contraire au protocole (en-tête absent ou mal formé).
    #[error("requête d'envoi invalide : {0}")]
    UploadInvalidRequest(String),
    /// Version du protocole d'envoi reprenable non prise en charge ; porte la version demandée.
    #[error("version du protocole d'envoi non prise en charge : {0}")]
    UploadVersionUnsupported(String),
    /// Opération interrompue par l'arrêt du serveur ; rien n'est perdu.
    #[error("opération interrompue par l'arrêt du serveur")]
    Cancelled,
    /// Contenu relu différent de la fiche (taille ou empreinte).
    #[error("fichier altéré : {0}")]
    IntegrityFailed(String),
}

impl StorageError {
    /// Code stable de l'erreur.
    pub fn code(&self) -> String {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => {
                    business.code.clone()
                }
                other => other
                    .transport_info()
                    .map(|info| info.code.to_string())
                    .unwrap_or_else(|| "ERROR_INVALID_FUNCTION_RESPONSE".to_string()),
            },
            Self::BackendUnknown(_) => "STORAGE_BACKEND_UNKNOWN".to_string(),
            Self::BackendUnavailable(_) => "STORAGE_BACKEND_UNAVAILABLE".to_string(),
            Self::ContentMismatch(_) => "STORAGE_CONTENT_MISMATCH".to_string(),
            Self::RangeNotSatisfiable(_) => "STORAGE_RANGE_NOT_SATISFIABLE".to_string(),
            Self::Infected(_) => "STORAGE_OBJECT_INFECTED".to_string(),
            Self::ScannerUnavailable(_) => "STORAGE_SCANNER_UNAVAILABLE".to_string(),
            Self::UploadOffsetMismatch(_) => "STORAGE_UPLOAD_OFFSET_MISMATCH".to_string(),
            Self::UploadInvalidRequest(_) => "STORAGE_UPLOAD_INVALID_REQUEST".to_string(),
            Self::UploadVersionUnsupported(_) => "STORAGE_UPLOAD_VERSION_UNSUPPORTED".to_string(),
            Self::Cancelled => "STORAGE_OPERATION_CANCELLED".to_string(),
            Self::IntegrityFailed(_) => "STORAGE_INTEGRITY_FAILED".to_string(),
        }
    }

    /// Vrai si l'erreur est un refus rendu par une fonction SurrealQL (code métier) : la base a
    /// répondu, l'opération n'a pas eu lieu. Faux pour une panne (transport, réponse illisible),
    /// après laquelle on ne sait pas si l'opération a eu lieu.
    pub fn is_business(&self) -> bool {
        matches!(self, Self::Surreal(error) if matches!(error.as_ref(), LyxalSurrealError::Call(LyxalCallError::Business(_))))
    }

    /// Vrai si l'opération peut réussir plus tard sans changement (base ou support indisponible).
    pub fn is_retryable(&self) -> bool {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.retryable,
                LyxalSurrealError::Call(_) => false,
                other => other.transport_info().is_some_and(|info| info.retryable),
            },
            Self::BackendUnavailable(_) | Self::ScannerUnavailable(_) | Self::Cancelled => true,
            Self::BackendUnknown(_)
            | Self::ContentMismatch(_)
            | Self::RangeNotSatisfiable(_)
            | Self::Infected(_)
            | Self::UploadOffsetMismatch(_)
            | Self::UploadInvalidRequest(_)
            | Self::UploadVersionUnsupported(_)
            | Self::IntegrityFailed(_) => false,
        }
    }
}

impl From<LyxalSurrealError> for StorageError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(error))
    }
}

impl From<object_store::Error> for StorageError {
    fn from(error: object_store::Error) -> Self {
        Self::BackendUnavailable(error.to_string())
    }
}

/// Résultat d'un service de `lyxal_storage`.
pub type StorageResult<T> = Result<T, StorageError>;
