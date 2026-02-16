//! # Leptos ShadCN UI
//! 
//! A comprehensive collection of beautiful, accessible UI components built for [Leptos](https://leptos.dev/) v0.8+, 
//! inspired by [shadcn/ui](https://ui.shadcn.com/).
//! 
//! ## Features
//! 
//! - **25+ Components**: Button, Input, Card, Alert, and many more
//! - **Leptos 0.8+**: Built specifically for Leptos v0.8+ compatibility
//! - **Accessibility First**: All components follow accessibility best practices
//! - **Tailwind CSS**: Seamless integration with Tailwind CSS
//! - **Type Safety**: Full Rust type safety with proper error handling
//! 
//! ## Usage
//! 
//! See the [README.md](../README.md) for complete installation and usage instructions.
//! 
//! **Note**: Make sure to enable the features for the components you want to use:
//! 
//! ```toml
//! [dependencies]
//! leptos-lyx-ui-shadcn = { path = "path/to/leptos-lyx-ui-shadcn/packages/leptos-lyx-ui-shadcn", features = ["button", "input", "card"] }
//! ```
//! 
//! ## Components
//! 
//! ### Form Components
//! - Button, Input, Label, Checkbox, Switch, Radio Group, Select, Textarea
//! 
//! ### Layout Components  
//! - Card, Separator, Tabs, Accordion, Dialog, Popover, Tooltip
//! 
//! ### Feedback & Status
//! - Alert, Badge, Skeleton, Progress, Toast, Table, Calendar, Date Picker, Pagination
//! 
//! ### Interactive Components
//! - Slider, Toggle
//! 
//! ### Performance Monitoring
//! - Performance Audit System - Comprehensive performance monitoring and optimization
//! - Bundle Size Analysis - Component size tracking and optimization recommendations
//! - Real-time Monitoring - Performance metrics collection and analysis
//! - CLI Tool - Command-line interface for running audits and generating reports
//! 
//! ## License
//! 
//! MIT License - see the [LICENSE](../LICENSE) file for details.

// Re-export all components (conditionally based on features)
#[cfg(feature = "button")]
pub use lyx_ui_button::*;
#[cfg(feature = "input")]
pub use lyx_ui_input::*;
#[cfg(feature = "label")]
pub use lyx_ui_label::*;
#[cfg(feature = "checkbox")]
pub use lyx_ui_checkbox::*;
#[cfg(feature = "switch")]
pub use lyx_ui_switch::*;
#[cfg(feature = "radio-group")]
pub use lyx_ui_radio_group::*;
#[cfg(feature = "select")]
pub use lyx_ui_select::*;
#[cfg(feature = "textarea")]
pub use lyx_ui_textarea::*;
#[cfg(feature = "card")]
pub use lyx_ui_card::*;
#[cfg(feature = "separator")]
pub use lyx_ui_separator::*;
#[cfg(feature = "tabs")]
pub use lyx_ui_tabs::*;
#[cfg(feature = "accordion")]
pub use lyx_ui_accordion::*;
#[cfg(feature = "dialog")]
pub use lyx_ui_dialog::*;
#[cfg(feature = "popover")]
pub use lyx_ui_popover::*;
#[cfg(feature = "tooltip")]
pub use lyx_ui_tooltip::*;
#[cfg(feature = "alert")]
pub use lyx_ui_alert::*;
#[cfg(feature = "badge")]
pub use lyx_ui_badge::*;
#[cfg(feature = "skeleton")]
pub use lyx_ui_skeleton::*;
#[cfg(feature = "progress")]
pub use lyx_ui_progress::*;
#[cfg(feature = "toast")]
pub use lyx_ui_toast::*;
#[cfg(feature = "table")]
pub use lyx_ui_table::*;
#[cfg(feature = "calendar")]
pub use lyx_ui_calendar::*;
#[cfg(feature = "date-picker")]
pub use lyx_ui_date_picker::*;
#[cfg(feature = "pagination")]
pub use lyx_ui_pagination::*;
#[cfg(feature = "slider")]
pub use lyx_ui_slider::*;
#[cfg(feature = "toggle")]
pub use lyx_ui_toggle::*;
#[cfg(feature = "drawer")]
pub use lyx_ui_drawer::*;
#[cfg(feature = "alert-dialog")]
pub use lyx_ui_alert_dialog::*;
#[cfg(feature = "context-menu")]
pub use lyx_ui_context_menu::*;
#[cfg(feature = "sheet")]
pub use lyx_ui_sheet::*;
#[cfg(feature = "avatar")]
pub use lyx_ui_avatar::*;
#[cfg(feature = "resizable")]
pub use lyx_ui_resizable::*;
#[cfg(feature = "performance-audit")]
pub use lyx_ui_performance_audit::*;

// Advanced components (newly fixed)
#[cfg(feature = "form")]
pub use lyx_ui_form::*;
#[cfg(feature = "combobox")]
pub use lyx_ui_combobox::*;
#[cfg(feature = "command")]
pub use lyx_ui_command::*;
#[cfg(feature = "input-otp")]
pub use lyx_ui_input_otp::*;
#[cfg(feature = "breadcrumb")]
pub use lyx_ui_breadcrumb::*;
#[cfg(feature = "lazy-loading")]
pub use lyx_ui_lazy_loading::*;
#[cfg(feature = "error-boundary")]
pub use lyx_ui_error_boundary::*;
#[cfg(feature = "registry")]
pub use lyx_ui_registry::*;
#[cfg(feature = "analytics")]
pub use lyx_ui_analytics::*;

// Re-export common types and utilities
pub use tailwind_fuse::tw_merge;

// Module documentation
#[cfg(feature = "all-components")]
pub mod prelude {
    //! # Leptos ShadCN UI Prelude
    //! 
    //! This module re-exports the most commonly used components and types.
    //! 
    //! ```rust
    //! use leptos_lyx_ui_shadcn::prelude::*;
    //! ```
    
    // Form components
    #[cfg(feature = "button")]
    pub use super::{Button, ButtonVariant, ButtonSize};
    #[cfg(feature = "input")]
    pub use super::Input;
    #[cfg(feature = "label")]
    pub use super::Label;
    #[cfg(feature = "checkbox")]
    pub use super::Checkbox;
    #[cfg(feature = "switch")]
    pub use super::Switch;
    #[cfg(feature = "radio-group")]
    pub use super::RadioGroup;
    #[cfg(feature = "select")]
    pub use super::Select;
    #[cfg(feature = "textarea")]
    pub use super::Textarea;
    
    // Layout components
    #[cfg(feature = "card")]
    pub use super::{Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter};
    #[cfg(feature = "separator")]
    pub use super::Separator;
    #[cfg(feature = "tabs")]
    pub use super::{Tabs, TabsList, TabsTrigger, TabsContent};
    #[cfg(feature = "accordion")]
    pub use super::{Accordion, AccordionItem, AccordionTrigger, AccordionContent};
    #[cfg(feature = "dialog")]
    pub use super::{Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter};
    #[cfg(feature = "popover")]
    pub use super::Popover;
    #[cfg(feature = "tooltip")]
    pub use super::{Tooltip, TooltipContent, TooltipTrigger, TooltipProvider};
    
    // Feedback components
    #[cfg(feature = "alert")]
    pub use super::{Alert, AlertTitle, AlertDescription, AlertVariant};
    #[cfg(feature = "badge")]
    pub use super::{Badge, BadgeVariant};
    #[cfg(feature = "skeleton")]
    pub use super::Skeleton;
    #[cfg(feature = "progress")]
    pub use super::{Progress, ProgressProps};
    #[cfg(feature = "toast")]
    pub use super::{Toast, ToastProps};
    #[cfg(feature = "table")]
    pub use super::Table;
    #[cfg(feature = "calendar")]
    pub use super::Calendar;
    #[cfg(feature = "date-picker")]
    pub use super::DatePicker;
    #[cfg(feature = "pagination")]
    pub use super::Pagination;
    
    // Interactive components
    #[cfg(feature = "slider")]
    pub use super::Slider;
    #[cfg(feature = "toggle")]
    pub use super::{Toggle, ToggleProps};
    
    // NEW Overlay & Advanced components
    #[cfg(feature = "drawer")]
    pub use super::{Drawer, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerTitle, DrawerTrigger};
    #[cfg(feature = "alert-dialog")]
    pub use super::{AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger};
    #[cfg(feature = "context-menu")]
    pub use super::{ContextMenu, ContextMenuCheckboxItem, ContextMenuContent, ContextMenuItem, ContextMenuLabel, ContextMenuRadioGroup, ContextMenuRadioItem, ContextMenuSeparator, ContextMenuShortcut, ContextMenuSub, ContextMenuSubContent, ContextMenuSubTrigger, ContextMenuTrigger};
    #[cfg(feature = "sheet")]
    pub use super::Sheet;
    #[cfg(feature = "command")]
    pub use super::{Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList, CommandSeparator, CommandShortcut};
    #[cfg(feature = "avatar")]
    pub use super::{Avatar, AvatarFallback, AvatarImage};
    
    // Utilities
    pub use super::tw_merge;
}

