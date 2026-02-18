//! Leptos port of shadcn/ui badge

mod signal_managed;
mod default;
mod new_york;

pub use default::{Badge, BadgeVariant};
pub use new_york::{Badge as BadgeNewYork, BadgeVariant as BadgeVariantNewYork};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
