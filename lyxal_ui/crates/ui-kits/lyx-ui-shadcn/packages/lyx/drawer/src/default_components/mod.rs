//! Drawer default components
//!
//! This module contains all the default drawer components organized into focused sub-modules
//! for better maintainability and readability.

mod types;
mod drawer;
mod trigger;
mod portal_overlay;
mod content;
mod header_footer;
mod title_description;
mod close;
mod nested;

// Re-export all components and types for easy access
pub use crate::default_components::types::*;
pub use crate::default_components::drawer::Drawer;
pub use crate::default_components::trigger::{DrawerTrigger, DrawerTriggerChildProps};
pub use crate::default_components::portal_overlay::{DrawerPortal, DrawerOverlay};
pub use crate::default_components::content::DrawerContent;
pub use crate::default_components::header_footer::{DrawerHeader, DrawerFooter};
pub use crate::default_components::title_description::{DrawerTitle, DrawerDescription};
pub use crate::default_components::close::{DrawerClose, DrawerCloseChildProps};
pub use crate::default_components::nested::DrawerNestedRoot;
