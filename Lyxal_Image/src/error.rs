use thiserror::Error;

#[derive(Error, Debug)]
pub enum LyxalError {
    #[error("Erreur de décodage image: {0}")]
    Decode(#[from] image::ImageError),

    #[error("Erreur d'encodage: {0}")]
    Encode(String),

    #[error("Erreur système de verrouillage (Lock poisoned)")]
    LockError,

    #[error("Quota dépassé: {0}")]
    QuotaExceeded(String),

    #[error("Paramètre invalide: {0}")]
    InvalidParam(String),

    #[error("Erreur ML/IA: {0}")]
    ModelError(String),

    #[error("Erreur Vectorielle (SVG): {0}")]
    VectorError(String),

    #[error("Erreur Texte: {0}")]
    TextError(String),
}

pub type LyxalResult<T> = Result<T, LyxalError>;