use thiserror::Error;
use crate::ops::OperationError;

#[derive(Error, Debug, PartialEq)]
pub enum HistoryError {
    #[error("Operation failed during replay: {0}")]
    OperationFailed(#[from] OperationError),
    
    #[error("No more history to undo")]
    NoMoreUndo,
    
    #[error("No more history to redo")]
    NoMoreRedo,
}

