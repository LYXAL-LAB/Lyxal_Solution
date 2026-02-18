//! Leptos port of shadcn/ui tabs

mod signal_managed;
mod default;
mod new_york;

pub use default::{
Tabs, TabsList, TabsTrigger, TabsContent
};
pub use new_york::{
Tabs as TabsNewYork, TabsList as TabsListNewYork, TabsTrigger as TabsTriggerNewYork, TabsContent as TabsContentNewYork
};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
