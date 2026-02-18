//! Leptos port of [shadcn/ui Tooltip](https://ui.shadcn.com/docs/components/tooltip).
//!
//! A tooltip component for displaying additional information on hover or focus.
//!
//! See [the Rust shadcn/ui book](https://lyx-ui-shadcn.rustforweb.org/components/tooltip.html) for more documentation.

mod signal_managed;
mod default;
mod new_york;

mod tests;

mod tdd_tests;

// Re-export the components for easy access
pub use default::*;

#[cfg(feature = "new_york")]
pub use new_york as tooltip;

// Signal-managed exports
pub use signal_managed::*;
