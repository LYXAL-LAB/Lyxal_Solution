//! Leptos port of shadcn/ui progress

mod signal_managed;
mod default;
mod new_york;

pub use default::{
Progress, ProgressRoot, ProgressIndicator, ProgressLabel, ProgressVariant, ProgressProps
};
pub use new_york::{
Progress as ProgressNewYork, ProgressRoot as ProgressRootNewYork,
ProgressIndicator as ProgressIndicatorNewYork, ProgressLabel as ProgressLabelNewYork,
ProgressVariant as ProgressVariantNewYork
};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
