//! Leptos port of shadcn/ui toggle

mod signal_managed;
mod default;
mod new_york;

pub use default::{Toggle, ToggleProps};
pub use new_york::{Toggle as ToggleNewYork};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
