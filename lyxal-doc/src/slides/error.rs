use thiserror::Error;

#[derive(Error, Debug, PartialEq, Clone)]
pub enum SlidesError {
    #[error("Layout error: {0}")]
    LayoutError(String),
    
    #[error("Interpretation failed: {0}")]
    InterpretationFailed(String),
}

