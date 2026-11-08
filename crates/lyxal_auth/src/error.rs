//! Erreurs des services Rust de `lyxal_auth`. Les erreurs métier viennent des fonctions SurrealQL
//! (codes `AUTH_*` de la master data), portées par `LyxalSurrealError`.

use lyxal_crypto::CryptoError;
use lyxal_surreal::{LyxalCallError, LyxalSurrealError};
use thiserror::Error;

/// Erreur d'un service de `lyxal_auth`. Aucune variante ne contient de jeton ni de secret.
#[derive(Debug, Error)]
pub enum AuthError {
    /// Échec d'une fonction SurrealQL (code `AUTH_*`) ou du transport.
    #[error("{0}")]
    Surreal(Box<LyxalSurrealError>),
    /// Échec cryptographique (génération, scellement).
    #[error("opération cryptographique : {0}")]
    Crypto(#[from] CryptoError),
    /// Paramètre refusé avant tout appel (ex. URL publique invalide).
    #[error("paramètre invalide : {0}")]
    InvalidParameter(&'static str),
    /// Lecture DNS impossible (résolveur indisponible ; un domaine sans enregistrement n'est pas
    /// une erreur mais une vérification échouée).
    #[error("lecture DNS impossible : {0}")]
    Dns(String),
    /// Refus décidé par un service Rust (code `AUTH_*` de la master data : identifiants
    /// incorrects, politique de mot de passe, verrouillage…), sans détail sur le compte.
    #[error("{0}")]
    Rejected(&'static str),
}

impl AuthError {
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
            Self::Crypto(_) => "AUTH_CRYPTO_ERROR".to_string(),
            Self::InvalidParameter(_) => "AUTH_INVALID_PARAMETERS".to_string(),
            Self::Dns(_) => "AUTH_DNS_UNAVAILABLE".to_string(),
            Self::Rejected(code) => (*code).to_string(),
        }
    }
}

impl From<LyxalSurrealError> for AuthError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Surreal(Box::new(error))
    }
}

impl AuthError {
    /// Vrai si l'erreur est le refus métier `code` (SurrealQL ou service Rust).
    pub fn is(&self, code: &str) -> bool {
        self.code() == code
    }
}

/// Résultat d'un service de `lyxal_auth`.
pub type AuthResult<T> = Result<T, AuthError>;
