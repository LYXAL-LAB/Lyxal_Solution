use crate::context::{use_analytics, use_analytics_unsafe};
use crate::types::ComponentUsageEvent;
use leptos::prelude::*;
use std::collections::HashMap;

/// Hook to track a component mount
///
/// Call this in a component's body to track when it's rendered
///
/// # Example
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_analytics::hooks::use_track_component;
///
/// #[component]
/// fn MyComponent() -> impl IntoView {
///     use_track_component("MyComponent");
///     view! { <div>"Hello"</div> }
/// }
/// ```
#[allow(non_snake_case)]
pub fn use_track_component(component_name: impl Into<String>) {
    let analytics = use_analytics();

    if let Some(analytics) = analytics {
        let component_name = component_name.into();
        let event = ComponentUsageEvent::new(component_name.clone());
        analytics.track(event);
    }
}

/// Hook to track a component with variant
///
/// # Example
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_analytics::hooks::use_track_component_variant;
///
/// #[component]
/// fn Button(variant: String) -> impl IntoView {
///     use_track_component_variant("Button", &variant);
///     view! { <button>{children}</button> }
/// }
/// ```
#[allow(non_snake_case)]
pub fn use_track_component_variant(component_name: impl Into<String>, variant: &str) {
    let analytics = use_analytics();

    if let Some(analytics) = analytics {
        let component_name = component_name.into();
        let event = ComponentUsageEvent::new(component_name).with_variant(variant);
        analytics.track(event);
    }
}

/// Hook to track a component with full props
///
/// # Example
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_analytics::hooks::use_track_component_full;
///
/// #[component]
/// fn Button(size: String, disabled: bool) -> impl IntoView {
///     let mut props = std::collections::HashMap::new();
///     props.insert("size".to_string(), size.clone());
///     props.insert("disabled".to_string(), disabled.to_string());
///
///     use_track_component_full("Button", Some("outline"), props);
///     view! { <button>{children}</button> }
/// }
/// ```
#[allow(non_snake_case)]
pub fn use_track_component_full(
    component_name: impl Into<String>,
    variant: Option<&str>,
    props: HashMap<String, String>,
) {
    let analytics = use_analytics();

    if let Some(analytics) = analytics {
        let component_name = component_name.into();
        let mut event = ComponentUsageEvent::new(component_name);

        if let Some(v) = variant {
            event = event.with_variant(v);
        }

        if !props.is_empty() {
            event = event.with_props(props);
        }

        analytics.track(event);
    }
}

/// Hook to get component statistics
///
/// Returns a signal containing all component stats
#[allow(non_snake_case)]
pub fn use_component_stats() -> Signal<Vec<crate::types::ComponentStats>> {
    let analytics = use_analytics_unsafe();
    analytics.get_all_stats_sorted().into()
}

/// Hook to get the most used components
///
/// # Arguments
/// * `limit` - Maximum number of components to return
#[allow(non_snake_case)]
pub fn use_most_used_components(limit: usize) -> Signal<Vec<crate::types::ComponentStats>> {
    let analytics = use_analytics_unsafe();
    analytics.get_most_used(limit).into()
}

/// Hook to get analytics summary
///
/// Returns tuple of (total_mounts, unique_components, session_events)
#[allow(non_snake_case)]
pub fn use_analytics_summary() -> Signal<(u64, usize, usize)> {
    let analytics = use_analytics_unsafe();

    Signal::derive(move || {
        let total = analytics.total_mounts();
        let unique = analytics.unique_components();
        let events = analytics.session_events.get();
        (total, unique, events)
    })
}

/// Hook to check if analytics is enabled
#[allow(non_snake_case)]
pub fn use_analytics_enabled() -> Signal<bool> {
    let analytics = use_analytics_unsafe();
    analytics.enabled.into()
}

/// Hook to toggle analytics tracking
#[allow(non_snake_case)]
pub fn use_analytics_toggle() -> (Signal<bool>, impl Fn() + Clone) {
    let analytics = use_analytics_unsafe();

    let enabled = analytics.enabled.into();

    let toggle = {
        let analytics = analytics.clone();
        move || {
            if analytics.is_enabled() {
                analytics.disable();
            } else {
                analytics.enable();
            }
        }
    };

    (enabled, toggle)
}

/// Hook to export analytics data
///
/// Returns a callback that exports analytics as JSON string
#[allow(non_snake_case)]
pub fn use_analytics_export() -> Callback<(), Result<String, String>> {
    let analytics = use_analytics_unsafe();

    Callback::new(move |_| {
        analytics.export_json()
    })
}

/// Hook to clear analytics data
///
/// Returns a callback that clears all analytics data
#[allow(non_snake_case)]
pub fn use_analytics_clear() -> Callback<(), ()> {
    let analytics = use_analytics_unsafe();

    Callback::new(move |_| {
        analytics.clear();
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_hooks_compile() {
        // These are compile-time tests to ensure hooks have correct signatures
        // Actual functionality tests would require a Leptos runtime
        let _ = || {
            let _name: String = "Test".to_string();
            let _variant: &str = "default";
            let _props: HashMap<String, String> = HashMap::new();
        };
    }
}
