//! Leptos port of shadcn/ui textarea

mod signal_managed;
mod default;
mod new_york;

pub use default::{Textarea};
pub use new_york::{Textarea as TextareaNewYork};

mod tests;

mod tdd_tests;

mod implementation_tests;

// Signal-managed exports
pub use signal_managed::*;
