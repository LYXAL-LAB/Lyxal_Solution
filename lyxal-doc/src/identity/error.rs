use thiserror::Error;
use crate::identity::hash::HashError;

#[derive(Error, Debug)]
pub enum IdentityError {
    #[error("Hash error: {0}")]
    Hash(#[from] HashError),
}

