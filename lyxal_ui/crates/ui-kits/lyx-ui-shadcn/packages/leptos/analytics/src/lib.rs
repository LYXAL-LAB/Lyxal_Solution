// Copyright (c) 2024-2025 Leptos Shadcn UI Contributors
// SPDX-License-Identifier: MIT

//! # Leptos Shadcn UI Analytics
//!
//! Component usage analytics tracking for Leptos applications.
//!
//! ## Features
//!
//! - Track component usage across your application
//! - Persistent storage with localStorage
//! - In-memory only mode for development
//! - Dashboard UI for visualizing analytics
//! - Export functionality for data analysis
//!
//! ## Quick Start
//!
//! ```rust
//! use leptos::prelude::*;
//! use leptos_shadcn_analytics::{AnalyticsProvider, dashboard::AnalyticsDashboard, hooks::use_track_component};
//!
//! #[component]
//! fn App() -> impl IntoView {
//!     view! {
//!         <AnalyticsProvider>
//!             <AnalyticsDashboard />
//!             <MyComponent />
//!         </AnalyticsProvider>
//!     }
//! }
//!
//! #[component]
//! fn MyComponent() -> impl IntoView {
//!     use_track_component("MyComponent");
//!     view! { <div>"Hello"</div> }
//! }
//! ```
//!
//! ## Configuration
//!
//! ```rust
//! use leptos_shadcn_analytics::types::{AnalyticsConfig, StorageMode};
//!
//! let config = AnalyticsConfig {
//!     storage_mode: StorageMode::LocalStorage,
//!     track_props: true,
//!     track_variants: true,
//!     ..Default::default()
//! };
//! ```

pub mod context;
pub mod dashboard;
pub mod hooks;
pub mod storage;
pub mod types;

// Re-exports for convenience
pub use context::{use_analytics, use_analytics_unsafe, AnalyticsContext, AnalyticsProvider};
pub use dashboard::{AnalyticsBadge, AnalyticsDashboard, format_timestamp};
pub use hooks::{
    use_analytics_clear, use_analytics_enabled, use_analytics_export, use_analytics_summary,
    use_analytics_toggle, use_component_stats, use_most_used_components, use_track_component,
    use_track_component_full, use_track_component_variant,
};
pub use storage::AnalyticsStorage;
pub use types::{
    AnalyticsConfig, ComponentStats, ComponentUsageEntry, ComponentUsageEvent, StoredAnalytics,
    StorageMode,
};

/// Version information
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
