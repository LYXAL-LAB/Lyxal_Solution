//! Leptos port of [shadcn/ui Aspect Ratio](https://ui.shadcn.com/docs/components/aspect-ratio).
//!
//! Displays content within a desired ratio.
//!
//! See [the Rust shadcn/ui book](https://lyx-ui-shadcn.rustforweb.org/components/aspect-ratio.html) for more documenation.

mod signal_managed;
mod default;
mod new_york;

// Re-export the components for easy access
pub use default::*;

#[cfg(feature = "new_york")]
pub use new_york as aspect_ratio;

mod tests;

// Signal-managed exports
pub use signal_managed::*;
