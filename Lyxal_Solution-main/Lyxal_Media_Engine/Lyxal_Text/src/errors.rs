use thiserror::Error;

#[derive(Error, Debug)]
pub enum TextError {
    #[error("Invalid Font: {0}")]
    InvalidFont(String),
    #[error("Shaping Error: {0}")]
    ShapingError(String),
    #[error("Invalid Input: {0}")]
    InvalidInput(String),
}

pub type TextResult<T> = Result<T, TextError>;
