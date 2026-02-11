//! Noyau Social Connect indépendant. SurrealDB n’intègre que du code finalisé, testé et figé.

pub mod capabilities;
pub mod error;
pub mod events;
pub mod providers;
pub mod runtime;
pub mod types;

pub use capabilities::Capabilities;
pub use error::{SocialError, SocialErrorCode, SocialResult};
pub use providers::{Provider, ProviderActionResult};
pub use types::{ProviderAccountKey, ProviderKind, SocialAction};

