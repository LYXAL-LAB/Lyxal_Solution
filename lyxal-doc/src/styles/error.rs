use thiserror::Error;

#[derive(Error, Debug, PartialEq, Clone)]
pub enum StyleError {
    #[error("Style not found: {0}")]
    StyleNotFound(String),
    
    #[error("Inheritance cycle detected: {0}")]
    InheritanceCycle(String),
    
    #[error("Invalid property value: {0}")]
    InvalidValue(String),
    
    #[error("Resolution failed: {0}")]
    ResolutionFailed(String),
}

