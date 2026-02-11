pub mod hash;
pub mod digest;
pub mod chain;
pub mod error;

pub use hash::{Hash, document_hash, compute_hash};
pub use digest::DocumentDigest;
pub use error::IdentityError;

