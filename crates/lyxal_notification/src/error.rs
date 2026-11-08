//! Erreurs des services Rust de `lyxal_notification`. Les erreurs métier viennent des fonctions
//! SurrealQL (codes `NOTIFICATION_*` de la master data), portées par `LyxalSurrealError`.

use lyxal_crypto::CryptoError;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use thiserror::Error;

/// Erreur d'un service de `lyxal_notification`. Aucune variante ne contient de secret ni de
/// contenu rendu.
#[derive(Debug, Error)]
pub enum NotificationError {
    /// Échec d'une fonction SurrealQL (code `NOTIFICATION_*`) ou du transport.
    #[error("{0}")]
    Surreal(Box<LyxalSurrealError>),
    /// Secret scellé illisible (clé absente, contexte différent, enveloppe altérée) ou contenu
    /// ouvert qui n'est pas un objet JSON.
    #[error("secret illisible : {0}")]
    Secret(String),
    /// Gabarit impossible à rendre (syntaxe, variable inconnue, budget dépassé, langue absente).
    #[error("rendu impossible : {0}")]
    Render(String),
    /// Configuration refusée (SMTP, adresse d'expéditeur).
    #[error("configuration invalide : {0}")]
    Configuration(String),
}

impl NotificationError {
    /// Code stable de l'erreur.
    pub fn code(&self) -> String {
        match self {
            Self::Surreal(error) => surreal_code(error),
            Self::Secret(_) => "NOTIFICATION_SECRET_UNAVAILABLE".to_string(),
            Self::Render(_) => "NOTIFICATION_RENDER_FAILED".to_string(),
            Self::Configuration(_) => "NOTIFICATION_SMTP_NOT_CONFIGURED".to_string(),
        }
    }

    /// Vrai si l'opération peut réussir plus tard sans changement (base indisponible).
    pub fn is_retryable(&self) -> bool {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.retryable,
                LyxalSurrealError::Call(_) => false,
                other => other.transport_info().is_some_and(|info| info.retryable),
            },
            _ => false,
        }
    }
}

fn surreal_code(error: &LyxalSurrealError) -> String {
    match error {
        LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.code.clone(),
        other => other
            .transport_info()
            .map(|info| info.code.to_string())
            .unwrap_or_else(|| "ERROR_INVALID_FUNCTION_RESPONSE".to_string()),
    }
}

impl From<LyxalSurrealError> for NotificationError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(error))
    }
}

impl From<CryptoError> for NotificationError {
    fn from(error: CryptoError) -> Self {
        Self::Secret(error.to_string())
    }
}

/// Résultat d'un service de `lyxal_notification`.
pub type NotificationResult<T> = Result<T, NotificationError>;
