use thiserror::Error;

#[derive(Error, Debug)]
pub enum VCardError {
    #[error("Parse error: {0}")]
    ParseError(String),
    #[error("Validation error: {0}")]
    ValidationError(String),
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
}

