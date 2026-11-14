//! Erreurs des services Rust de `lyxal_secrets`. Les erreurs métier viennent des fonctions
//! SurrealQL (codes `SECRETS_*` de la master data), portées par `LyxalSurrealError` ; les autres
//! sont constatées par le service (chiffrement indisponible, valeur trop grande, enveloppe
//! illisible). Aucune variante ne contient de valeur, de clé ni d'enveloppe.

use lyxal_crypto::CryptoError;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use thiserror::Error;

/// Code d'erreur : aucun rotateur inscrit ne gère le secret.
pub(crate) const ROTATOR_UNAVAILABLE: &str = "SECRETS_ROTATOR_UNAVAILABLE";

/// Erreur d'un service de `lyxal_secrets`.
#[derive(Debug, Error)]
pub enum SecretsError {
    /// Échec d'une fonction SurrealQL (code `SECRETS_*`) ou du transport.
    #[error("{0}")]
    Surreal(Box<LyxalSurrealError>),
    /// Clé maîtresse du coffre-fort absente : aucune valeur n'est écrite ni lue (R5).
    #[error("chiffrement indisponible : clé maîtresse du coffre-fort absente")]
    CryptoUnavailable,
    /// Valeur plus grande que la taille permise par les réglages.
    #[error("valeur trop grande : {size} octets pour {max} au plus")]
    ValueTooLarge {
        /// Taille de la valeur, en octets.
        size: usize,
        /// Taille maximale des réglages, en octets.
        max: i64,
    },
    /// Enveloppe qui ne s'ouvre pas : altérée, recopiée d'ailleurs ou scellée par une clé
    /// inconnue. Jamais une valeur vide.
    #[error("valeur illisible : enveloppe altérée ou scellée par une autre clé")]
    ValueCorrupted,
    /// Clé de l'organisation absente ou illisible par la clé maîtresse.
    #[error("clé d'organisation indisponible : {0}")]
    TenantKeyUnavailable(String),
    /// Échec d'une opération de chiffrement (tirage aléatoire, contexte, trousseau).
    #[error("opération de chiffrement en échec : {0}")]
    Crypto(CryptoError),
    /// Identifiant reçu inutilisable (organisation ou secret).
    #[error("identifiant invalide : {0}")]
    InvalidRecord(String),
    /// Aucun rotateur inscrit ne gère ce secret.
    #[error("aucun rotateur pour ce secret")]
    RotatorUnavailable,
}

impl SecretsError {
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
            Self::CryptoUnavailable | Self::Crypto(_) => "SECRETS_CRYPTO_UNAVAILABLE".to_string(),
            Self::ValueTooLarge { .. } => "SECRETS_VALUE_TOO_LARGE".to_string(),
            Self::ValueCorrupted => "SECRETS_VALUE_CORRUPTED".to_string(),
            Self::TenantKeyUnavailable(_) => "SECRETS_TENANT_KEY_UNAVAILABLE".to_string(),
            Self::InvalidRecord(_) => "SECRETS_INVALID_PARAMETERS".to_string(),
            Self::RotatorUnavailable => ROTATOR_UNAVAILABLE.to_string(),
        }
    }

    /// Vrai si l'erreur est un refus rendu par une fonction SurrealQL (code métier) : la base a
    /// répondu, l'opération n'a pas eu lieu. Faux pour une panne (transport, réponse illisible)
    /// et pour les erreurs constatées par le service.
    pub fn is_business(&self) -> bool {
        matches!(self, Self::Surreal(error) if matches!(error.as_ref(), LyxalSurrealError::Call(LyxalCallError::Business(_))))
    }

    /// Vrai si l'erreur métier porte ce code.
    pub fn is_code(&self, code: &str) -> bool {
        matches!(self, Self::Surreal(error) if matches!(error.as_ref(), LyxalSurrealError::Call(call) if call.is_business_code(code)))
    }

    /// Vrai si une écriture concurrente a pris la place : refus `code` de la base, ou conflit
    /// transitoire de transaction de SurrealDB (transaction annulée, rien n'a été écrit).
    pub fn is_conflict(&self, code: &str) -> bool {
        self.is_code(code) || matches!(self, Self::Surreal(error) if error.is_transient_conflict())
    }

    /// Vrai si l'opération peut réussir plus tard sans changement (base indisponible).
    pub fn is_retryable(&self) -> bool {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.retryable,
                LyxalSurrealError::Call(_) => false,
                other => other.transport_info().is_some_and(|info| info.retryable),
            },
            Self::CryptoUnavailable
            | Self::ValueTooLarge { .. }
            | Self::ValueCorrupted
            | Self::TenantKeyUnavailable(_)
            | Self::Crypto(_)
            | Self::InvalidRecord(_)
            | Self::RotatorUnavailable => false,
        }
    }
}

impl From<LyxalSurrealError> for SecretsError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(error))
    }
}

impl From<CryptoError> for SecretsError {
    fn from(error: CryptoError) -> Self {
        Self::Crypto(error)
    }
}

/// Résultat d'un service de `lyxal_secrets`.
pub type SecretsResult<T> = Result<T, SecretsError>;
