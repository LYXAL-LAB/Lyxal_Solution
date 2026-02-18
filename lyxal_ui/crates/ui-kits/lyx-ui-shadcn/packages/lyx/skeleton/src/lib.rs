//! Leptos port of shadcn/ui skeleton

mod signal_managed;
mod default;
mod new_york;

pub use default::{
Skeleton, SkeletonText, SkeletonAvatar, SkeletonCard, SkeletonVariant, SkeletonSize
};
pub use new_york::{
Skeleton as SkeletonNewYork, SkeletonText as SkeletonTextNewYork,
SkeletonAvatar as SkeletonAvatarNewYork, SkeletonCard as SkeletonCardNewYork,
SkeletonVariant as SkeletonVariantNewYork, SkeletonSize as SkeletonSizeNewYork
};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
