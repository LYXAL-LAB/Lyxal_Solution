// SPDX-License-Identifier: AGPL-3.0-only

//! Erreurs des services Rust de `lyxal_mail`. Les erreurs métier viennent des fonctions
//! SurrealQL (codes `MAIL_*` de la master data), portées par `LyxalSurrealError` ; celles du
//! stockage gardent leur code `STORAGE_*`. Aucune variante ne contient d'adresse, de sujet ni
//! de contenu de message.

use lyxal_mail_proto::mime::MimeError;
use lyxal_storage::StorageError;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use thiserror::Error;

/// Erreur d'un service de `lyxal_mail`.
#[derive(Debug, Error)]
pub enum MailError {
    /// Échec d'une fonction SurrealQL (code `MAIL_*`) ou du transport.
    #[error("{0}")]
    Surreal(Box<LyxalSurrealError>),
    /// Échec du stockage des fichiers (code `STORAGE_*`).
    #[error("{0}")]
    Storage(Box<StorageError>),
    /// Message illisible : vide, sans en-tête, ou au-delà des limites de lecture MIME
    /// (`MAIL_MESSAGE_MALFORMED`).
    #[error("message illisible : {0}")]
    Malformed(MimeError),
    /// Contenu indisponible pour l'instant : service de clés absent (clé maîtresse du
    /// coffre-fort), aucun support de stockage, bucket `lyxal-mail` de l'organisation en clair,
    /// ou mémoire des dépôts épuisée (`MAIL_CONTENT_UNAVAILABLE`, à réessayer). Rien n'est
    /// écrit.
    #[error("contenu indisponible : {0}")]
    Unavailable(String),
    /// Message d'un lot de remise refusé par `fn::mail_delivery_commit` (code `MAIL_*` de cet
    /// élément : quota, taille, contenu) ; les autres messages du lot sont inscrits.
    #[error("{code}")]
    Refused {
        /// Code `MAIL_*`.
        code: String,
        /// L'élément peut réussir plus tard sans changement.
        retryable: bool,
    },
}

impl MailError {
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
            Self::Storage(error) => error.code(),
            Self::Malformed(_) => "MAIL_MESSAGE_MALFORMED".to_string(),
            Self::Unavailable(_) => "MAIL_CONTENT_UNAVAILABLE".to_string(),
            Self::Refused { code, .. } => code.clone(),
        }
    }

    /// Vrai si l'erreur est un refus rendu par une fonction SurrealQL (code métier) : la base a
    /// répondu, l'opération n'a pas eu lieu. Faux pour une panne (transport, réponse
    /// illisible), après laquelle on ne sait pas si l'opération a eu lieu.
    pub fn is_business(&self) -> bool {
        match self {
            Self::Surreal(error) => matches!(
                error.as_ref(),
                LyxalSurrealError::Call(LyxalCallError::Business(_))
            ),
            Self::Storage(error) => error.is_business(),
            Self::Refused { .. } => true,
            Self::Malformed(_) | Self::Unavailable(_) => false,
        }
    }

    /// Vrai si l'opération peut réussir plus tard sans changement (base, stockage ou clés
    /// indisponibles, conflit d'écriture).
    pub fn is_retryable(&self) -> bool {
        match self {
            Self::Surreal(error) => match error.as_ref() {
                LyxalSurrealError::Call(LyxalCallError::Business(business)) => business.retryable,
                LyxalSurrealError::Call(_) => false,
                other => {
                    other.is_transient_conflict()
                        || other.transport_info().is_some_and(|info| info.retryable)
                }
            },
            Self::Storage(error) => error.is_retryable(),
            Self::Unavailable(_) => true,
            Self::Refused { retryable, .. } => *retryable,
            Self::Malformed(_) => false,
        }
    }
}

impl From<LyxalSurrealError> for MailError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(error))
    }
}

impl From<StorageError> for MailError {
    fn from(error: StorageError) -> Self {
        match error {
            StorageError::Surreal(inner) => Self::Surreal(inner),
            other => Self::Storage(Box::new(other)),
        }
    }
}

impl From<MimeError> for MailError {
    fn from(error: MimeError) -> Self {
        Self::Malformed(error)
    }
}

/// Résultat d'un service de `lyxal_mail`.
pub type MailResult<T> = Result<T, MailError>;
