//! Sonner toast component
//! 
//! This module contains the complete Sonner toast system,
//! organized into focused sub-modules for better maintainability and readability.

mod types;
mod builder;
mod context;
mod toast_component;
mod api;

// Re-export the main components and types
pub use types::*;
pub use builder::ToastBuilder;
pub use context::{SonnerProvider, SonnerViewport, SonnerContextValue};
pub use toast_component::SonnerToast;
pub use api::toast;
