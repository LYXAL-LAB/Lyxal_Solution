use thiserror::Error;

#[derive(Error, Debug, PartialEq, Clone)]
pub enum DrawError {
    #[error("Geometry error: {0}")]
    GeometryError(String),
    
    #[error("Interpretation failed: {0}")]
    InterpretationFailed(String),
}

