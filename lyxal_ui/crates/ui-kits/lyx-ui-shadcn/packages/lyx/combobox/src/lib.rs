//! Leptos port of shadcn/ui Combobox component
//!
//! Provides an autocomplete input component with a list of suggestions.

mod signal_managed;
mod default;
mod new_york;

// Re-export common types
pub use default::{Combobox, ComboboxOption};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
