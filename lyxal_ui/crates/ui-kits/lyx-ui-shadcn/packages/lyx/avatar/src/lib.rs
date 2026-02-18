//! Leptos port of shadcn/ui avatar

mod signal_managed;
mod default;
mod new_york;

pub use default::{Avatar, AvatarImage, AvatarFallback, AvatarGroup};
pub use new_york::{Avatar as AvatarNewYork, AvatarImage as AvatarImageNewYork, AvatarFallback as AvatarFallbackNewYork, AvatarGroup as AvatarGroupNewYork};

mod tests;

// Signal-managed exports
pub use signal_managed::*;
