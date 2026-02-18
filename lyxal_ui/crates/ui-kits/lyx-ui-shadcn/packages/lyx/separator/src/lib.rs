//! Leptos port of shadcn/ui separator

mod signal_managed;
mod default;
mod new_york;

pub use default::{Separator};
pub use new_york::{Separator as SeparatorNewYork};

mod tests;

// Signal-managed exports
pub use signal_managed::*;
