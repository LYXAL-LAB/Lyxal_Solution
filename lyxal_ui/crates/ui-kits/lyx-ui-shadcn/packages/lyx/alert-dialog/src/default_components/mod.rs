//! AlertDialog default components
//! 
//! This module contains all the default alert dialog components organized into focused sub-modules
//! for better maintainability and readability.

mod alert_dialog;
mod trigger;
mod overlay;
mod content;
mod header_footer;
mod title_description;
mod action_cancel;

// Re-export all components for easy access
pub use crate::default_components::alert_dialog::AlertDialog;
pub use crate::default_components::trigger::AlertDialogTrigger;
pub use crate::default_components::overlay::AlertDialogOverlay;
pub use crate::default_components::content::AlertDialogContent;
pub use crate::default_components::header_footer::{AlertDialogHeader, AlertDialogFooter};
pub use crate::default_components::title_description::{AlertDialogTitle, AlertDialogDescription};
pub use crate::default_components::action_cancel::{AlertDialogAction, AlertDialogCancel};
