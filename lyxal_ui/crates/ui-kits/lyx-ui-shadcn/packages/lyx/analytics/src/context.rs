use crate::storage::AnalyticsStorage;
use crate::types::{
    AnalyticsConfig, ComponentStats, ComponentUsageEvent, StoredAnalytics, StorageMode,
};
use leptos::prelude::*;

/// Global analytics context that holds all tracking state
#[derive(Debug, Clone)]
pub struct AnalyticsContext {
    /// The current analytics data
    pub analytics: RwSignal<StoredAnalytics>,
    /// Configuration for analytics
    pub config: AnalyticsConfig,
    /// Storage handler
    storage: AnalyticsStorage,
    /// Whether tracking is enabled
    pub enabled: RwSignal<bool>,
    /// Total events tracked in current session
    pub session_events: RwSignal<usize>,
}

impl AnalyticsContext {
    /// Create a new analytics context
    pub fn new(config: AnalyticsConfig) -> Self {
        let storage = AnalyticsStorage::new(config.storage_key.clone(), config.storage_mode);
        let initial = storage.load().unwrap_or_default();

        Self {
            analytics: RwSignal::new(initial),
            config,
            storage,
            enabled: RwSignal::new(true),
            session_events: RwSignal::new(0),
        }
    }

    /// Track a component usage event
    pub fn track(&self, event: ComponentUsageEvent) {
        if !self.enabled.get() {
            return;
        }

        // Update session event count
        self.session_events.update(|count| *count += 1);

        // Update analytics data
        self.analytics.update(|analytics| {
            let stats = analytics
                .stats
                .entry(event.component_name.clone())
                .or_insert_with(|| ComponentStats::new(&event.component_name));

            stats.record_event(&event);
        });

        // Persist if needed
        if self.config.storage_mode != StorageMode::MemoryOnly {
            let _ = self.storage.save(&self.analytics.get());
        }
    }

    /// Get stats for a specific component
    pub fn get_component_stats(&self, component_name: &str) -> Option<ComponentStats> {
        self.analytics
            .with(|analytics| analytics.stats.get(component_name).cloned())
    }

    /// Get all component stats sorted by usage
    pub fn get_all_stats_sorted(&self) -> Vec<ComponentStats> {
        let mut stats: Vec<_> = self
            .analytics
            .with(|analytics| analytics.stats.values().cloned().collect());
        stats.sort_by(|a, b| b.mount_count.cmp(&a.mount_count));
        stats
    }

    /// Get the most used components
    pub fn get_most_used(&self, limit: usize) -> Vec<ComponentStats> {
        let mut stats = self.get_all_stats_sorted();
        stats.truncate(limit);
        stats
    }

    /// Clear all analytics data
    pub fn clear(&self) {
        self.analytics.update(|analytics| {
            analytics.stats.clear();
            analytics.session_start = js_sys::Date::now() as u64;
        });
        self.session_events.set(0);
        let _ = self.storage.clear();
    }

    /// Export analytics as JSON
    pub fn export_json(&self) -> Result<String, String> {
        self.storage
            .export_json(&self.analytics.get())
            .map_err(|e| e.to_string())
    }

    /// Get total number of component mounts
    pub fn total_mounts(&self) -> u64 {
        self.analytics
            .with(|analytics| analytics.stats.values().map(|s| s.mount_count).sum())
    }

    /// Get the number of unique components tracked
    pub fn unique_components(&self) -> usize {
        self.analytics.with(|analytics| analytics.stats.len())
    }

    /// Enable tracking
    pub fn enable(&self) {
        self.enabled.set(true);
    }

    /// Disable tracking
    pub fn disable(&self) {
        self.enabled.set(false);
    }

    /// Check if tracking is enabled
    pub fn is_enabled(&self) -> bool {
        self.enabled.get()
    }
}

/// Provider component for analytics context
#[component]
pub fn AnalyticsProvider(
    /// Configuration for analytics
    #[prop(optional)] config: Option<AnalyticsConfig>,
    /// Children components
    children: Children,
) -> impl IntoView {
    let context = AnalyticsContext::new(config.unwrap_or_default());

    provide_context(context);

    children()
}

/// Hook to access the analytics context
///
/// Returns `None` if used outside of an `AnalyticsProvider`
#[allow(non_snake_case)]
pub fn use_analytics() -> Option<AnalyticsContext> {
    use_context()
}

/// Hook to access the analytics context with panic if not available
///
/// Panics if used outside of an `AnalyticsProvider`
#[allow(non_snake_case)]
pub fn use_analytics_unsafe() -> AnalyticsContext {
    use_analytics().expect(
        "use_analytics_unsafe() called outside of AnalyticsProvider. \
         Make sure your app is wrapped with <AnalyticsProvider>.",
    )
}

/// Hook to track component usage
///
/// Returns a callback that can be used to track component events
#[allow(non_snake_case)]
pub fn use_component_tracker() -> Option<Callback<String>> {
    let analytics = use_analytics()?;

    Some(Callback::new(move |component_name: String| {
        let event = ComponentUsageEvent::new(component_name);
        analytics.track(event);
    }))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_analytics_context_creation() {
        let config = AnalyticsConfig::default();
        let context = AnalyticsContext::new(config);

        assert_eq!(context.total_mounts(), 0);
        assert_eq!(context.unique_components(), 0);
        assert!(context.is_enabled());
    }

    #[test]
    fn test_component_stats_new() {
        let stats = ComponentStats::new("Button");
        assert_eq!(stats.component_name, "Button");
        assert_eq!(stats.mount_count, 0);
        assert!(stats.variant_counts.is_empty());
    }

    #[test]
    fn test_component_usage_event_new() {
        let event = ComponentUsageEvent::new("Button");
        assert_eq!(event.component_name, "Button");
        assert!(event.variant.is_none());
        assert!(event.props.is_none());
    }

    #[test]
    fn test_component_usage_event_with_variant() {
        let event = ComponentUsageEvent::new("Button").with_variant("outline");
        assert_eq!(event.component_name, "Button");
        assert_eq!(event.variant.as_deref(), Some("outline"));
    }

    #[test]
    fn test_component_stats_record_event() {
        let mut stats = ComponentStats::new("Button");
        let event = ComponentUsageEvent::new("Button").with_variant("outline");
        stats.record_event(&event);

        assert_eq!(stats.mount_count, 1);
        assert_eq!(stats.variant_counts.get("outline"), Some(&1));
    }
}
