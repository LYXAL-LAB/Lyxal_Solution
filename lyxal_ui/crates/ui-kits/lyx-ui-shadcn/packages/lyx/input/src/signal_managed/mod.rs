//! Signal-Managed Input Components
//!
//! This module contains signal-managed versions of the Input component with advanced
//! signal management capabilities using leptos-shadcn-signal-management.

mod types;
mod basic_input;
mod enhanced_input;

// Re-export the main components and types
pub use types::{SignalManagedInputState, INPUT_CLASS, INPUT_ERROR_CLASS};
pub use basic_input::SignalManagedInput;
pub use enhanced_input::EnhancedInput;
