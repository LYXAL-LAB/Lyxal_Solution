use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Usage tracking data for a single component instance
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ComponentUsageEvent {
    /// Name of the component (e.g., "Button", "Input")
    pub component_name: String,
    /// Timestamp when the component was mounted
    pub timestamp: u64,
    /// Optional variant used (e.g., "default", "outline")
    pub variant: Option<String>,
    /// Optional props used
    pub props: Option<HashMap<String, String>>,
    /// Session ID to group events by session
    pub session_id: String,
}

impl ComponentUsageEvent {
    /// Create a new component usage event
    pub fn new(component_name: impl Into<String>) -> Self {
        Self {
            component_name: component_name.into(),
            timestamp: js_sys::Date::now() as u64,
            variant: None,
            props: None,
            session_id: Self::generate_session_id(),
        }
    }

    /// Add variant information
    pub fn with_variant(mut self, variant: impl Into<String>) -> Self {
        self.variant = Some(variant.into());
        self
    }

    /// Add props information
    pub fn with_props(mut self, props: HashMap<String, String>) -> Self {
        self.props = Some(props);
        self
    }

    /// Generate a session ID
    fn generate_session_id() -> String {
        // Use a combination of timestamp and random for session ID
        let timestamp = js_sys::Date::now();
        format!("session-{}", timestamp as u32)
    }
}

/// Aggregated statistics for a component
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct ComponentStats {
    /// Name of the component
    pub component_name: String,
    /// Total number of times this component was mounted
    pub mount_count: u64,
    /// Count by variant
    pub variant_counts: HashMap<String, u64>,
    /// First time this component was seen
    pub first_seen: u64,
    /// Last time this component was seen
    pub last_seen: u64,
}

impl ComponentStats {
    /// Create new stats for a component
    pub fn new(component_name: impl Into<String>) -> Self {
        let name = component_name.into();
        Self {
            component_name: name.clone(),
            mount_count: 0,
            variant_counts: HashMap::new(),
            first_seen: js_sys::Date::now() as u64,
            last_seen: js_sys::Date::now() as u64,
        }
    }

    /// Record a new usage event
    pub fn record_event(&mut self, event: &ComponentUsageEvent) {
        self.mount_count += 1;
        self.last_seen = event.timestamp;

        if let Some(variant) = &event.variant {
            *self.variant_counts.entry(variant.clone()).or_insert(0) += 1;
        }
    }
}

/// Analytics storage configuration
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StorageMode {
    /// Store data in memory only (lost on page refresh)
    MemoryOnly,
    /// Store data in localStorage (persists across sessions)
    LocalStorage,
    /// Store in both memory and localStorage
    Hybrid,
}

impl Default for StorageMode {
    fn default() -> Self {
        Self::MemoryOnly
    }
}

/// Analytics configuration options
#[derive(Debug, Clone, PartialEq)]
pub struct AnalyticsConfig {
    /// Storage mode for analytics data
    pub storage_mode: StorageMode,
    /// Whether to track component props
    pub track_props: bool,
    /// Whether to track variants
    pub track_variants: bool,
    /// Maximum number of events to keep in memory
    pub max_events: usize,
    /// localStorage key for persistence
    pub storage_key: String,
}

impl Default for AnalyticsConfig {
    fn default() -> Self {
        Self {
            storage_mode: StorageMode::MemoryOnly,
            track_props: false,
            track_variants: true,
            max_events: 1000,
            storage_key: "leptos-analytics".to_string(),
        }
    }
}

impl AnalyticsConfig {
    /// Create a new config with localStorage persistence
    pub fn persistent() -> Self {
        Self {
            storage_mode: StorageMode::LocalStorage,
            ..Default::default()
        }
    }

    /// Create a new config with hybrid storage
    pub fn hybrid() -> Self {
        Self {
            storage_mode: StorageMode::Hybrid,
            ..Default::default()
        }
    }
}

/// Analytics data stored in localStorage
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct StoredAnalytics {
    /// Component statistics
    pub stats: HashMap<String, ComponentStats>,
    /// Session start time
    pub session_start: u64,
}

impl StoredAnalytics {
    /// Create new stored analytics
    pub fn new() -> Self {
        Self {
            stats: HashMap::new(),
            session_start: js_sys::Date::now() as u64,
        }
    }
}

impl Default for StoredAnalytics {
    fn default() -> Self {
        Self::new()
    }
}

/// Sorted component usage entry for dashboard display
#[derive(Debug, Clone, PartialEq)]
pub struct ComponentUsageEntry {
    pub component_name: String,
    pub count: u64,
    pub percentage: f32,
}
