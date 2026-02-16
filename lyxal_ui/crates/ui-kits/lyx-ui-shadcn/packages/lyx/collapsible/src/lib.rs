//! Leptos port of shadcn/ui collapsible

mod signal_managed;
mod default;
mod new_york;

pub use default::{
    Collapsible, CollapsibleTrigger, CollapsibleContent,
};

pub use new_york::{
    Collapsible as CollapsibleNewYork,
    CollapsibleTrigger as CollapsibleTriggerNewYork,
    CollapsibleContent as CollapsibleContentNewYork,
};

mod tests;

// Signal-managed exports
pub use signal_managed::*;
