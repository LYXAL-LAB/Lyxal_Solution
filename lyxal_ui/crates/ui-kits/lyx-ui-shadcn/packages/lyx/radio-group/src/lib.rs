//! Leptos port of [shadcn/ui Radio Group](https://ui.shadcn.com/docs/components/radio-group).
//!
//! A set of checkable buttons—known as radio buttons—where no more than one of the buttons can be checked at a time.
//!
//! See [the Rust shadcn/ui book](https://lyx-ui-shadcn.rustforweb.org/components/radio-group.html) for more documenation.

mod signal_managed;
mod default;
mod new_york;

// Re-export the components for easy access
pub use default::{RadioGroup, RadioGroupItem};
pub use new_york::{RadioGroup as RadioGroupNewYork, RadioGroupItem as RadioGroupItemNewYork};

mod tests;

mod tdd_tests;

mod implementation_tests;

// Signal-managed exports
pub use signal_managed::*;
