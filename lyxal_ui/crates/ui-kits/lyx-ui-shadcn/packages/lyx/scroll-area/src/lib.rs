//! Leptos port of shadcn/ui scroll-area

mod signal_managed;
mod default;
mod new_york;

pub use default::{ScrollArea};
pub use new_york::{ScrollArea as ScrollAreaNewYork};

mod tests;

// Signal-managed exports
pub use signal_managed::*;
