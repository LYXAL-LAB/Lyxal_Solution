pub mod core;
pub mod error;
pub mod context;
pub mod ops;
pub mod filters;
pub mod vector;
pub mod text;
pub mod ml;
pub mod secure;
pub mod pipeline;

// Exports publics pour faciliter l'utilisation externe
pub use core::LyxalImage;
pub use error::{LyxalError, LyxalResult};
pub use context::ImageContext;
pub use pipeline::process;
pub use ml::FaceDetector;