use thiserror::Error;

#[derive(Error, Debug, PartialEq)]
pub enum WordError {
    #[error("Layout error: {0}")]
    LayoutError(String),
    
    #[error("Interpretation failed: {0}")]
    InterpretationFailed(String),
}

