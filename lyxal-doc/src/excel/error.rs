use thiserror::Error;

#[derive(Error, Debug, PartialEq, Clone)]
pub enum ExcelError {
    #[error("Cycle detected in dependencies: #CYCLE!")]
    CycleDetected,
    
    #[error("Reference error: #REF!")]
    ReferenceError(String),
    
    #[error("Value error: #VALUE!")]
    ValueError(String),
    
    #[error("Name error: #NAME?")]
    NameError(String),
    
    #[error("Interpretation failed: {0}")]
    InterpretationFailed(String),
}

