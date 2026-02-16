//! Leptos port of shadcn/ui label

mod signal_managed;
mod default;
mod new_york;

pub use default::{Label};
pub use new_york::{Label as LabelNewYork};

mod tests;

mod tdd_tests;

mod implementation_tests;

// Signal-managed exports
pub use signal_managed::*;
