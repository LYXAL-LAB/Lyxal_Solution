use thiserror::Error;
use crate::validate::ValidationError;

#[derive(Error, Debug, PartialEq)]
pub enum OperationError {
    #[error("Invalid path: {0}")]
    InvalidPath(String),
    
    #[error("Index out of bounds")]
    OutOfBounds,
    
    #[error("Invariant violation: {0}")]
    InvariantViolation(#[from] ValidationError),
    
    #[error("Unsupported operation: {0}")]
    UnsupportedOperation(String),
    
    #[error("Node not found: {0}")]
    NodeNotFound(String),
}

