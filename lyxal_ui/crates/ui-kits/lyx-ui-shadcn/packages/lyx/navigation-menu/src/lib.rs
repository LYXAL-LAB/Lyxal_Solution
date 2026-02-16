//! Leptos port of shadcn/ui navigation-menu

mod signal_managed;
mod default;
mod new_york;

pub use default::{NavigationMenu};
pub use new_york::{NavigationMenu as NavigationMenuNewYork};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
