//! Leptos port of shadcn/ui alert

mod signal_managed;
mod default;
mod new_york;

pub use default::{Alert, AlertTitle, AlertDescription, AlertVariant};
pub use new_york::{Alert as AlertNewYork, AlertTitle as AlertTitleNewYork, AlertDescription as AlertDescriptionNewYork, AlertVariant as AlertVariantNewYork};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
