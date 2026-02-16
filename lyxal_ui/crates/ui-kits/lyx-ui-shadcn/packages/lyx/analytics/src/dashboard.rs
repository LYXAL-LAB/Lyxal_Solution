use crate::context::use_analytics;
use crate::hooks::{use_analytics_summary, use_analytics_toggle, use_most_used_components};
use leptos::prelude::*;

/// Analytics dashboard component that displays component usage statistics
#[component]
pub fn AnalyticsDashboard(
    /// Maximum number of components to show in the list
    #[prop(default = 20)]
    limit: usize,
    /// Whether to show the export/clear buttons
    #[prop(default = true)]
    show_actions: bool,
) -> impl IntoView {
    let analytics = use_analytics();

    let content = if analytics.is_some() {
        let most_used = use_most_used_components(limit);
        let summary = use_analytics_summary();
        let (enabled, toggle_tracking) = use_analytics_toggle();

        view! {
            <div class="analytics-dashboard">
                <h2>"Component Usage Analytics"</h2>
                <button onclick=move || toggle_tracking()>
                    {move || if enabled.get() { "Tracking On" } else { "Tracking Off" }}
                </button>
                <div>
                    <p>"Total Mounts: "{move || summary.get().0}</p>
                    <p>"Unique Components: "{move || summary.get().1}</p>
                    <p>"Session Events: "{move || summary.get().2}</p>
                </div>
                <div>
                    <h3>"Most Used Components"</h3>
                    {move || {
                        let components = most_used.get();
                        if components.is_empty() {
                            view! { <p>"No components tracked yet."</p> }.into_any()
                        } else {
                            view! {
                                <ul>
                                    {components.into_iter().map(|stat| {
                                        view! {
                                            <li>{stat.component_name}: {stat.mount_count}</li>
                                        }
                                    }).collect_view()}
                                </ul>
                            }.into_any()
                        }
                    }}
                </div>
                {show_actions.then(|| {
                    view! {
                        <button>"Export Data"</button>
                        <button>"Clear Data"</button>
                    }
                })}
            </div>
        }.into_any()
    } else {
        view! {
            <div class="analytics-error">"AnalyticsDashboard must be used inside an AnalyticsProvider"</div>
        }.into_any()
    };

    content
}

/// Simple analytics badge showing component count
#[component]
pub fn AnalyticsBadge(
    /// Position of the badge
    #[prop(default = "bottom-right".to_string())]
    position: String,
) -> impl IntoView {
    let analytics = use_analytics();

    let content = if analytics.is_some() {
        let summary = use_analytics_summary();
        view! {
            <div class="analytics-badge">
                <div>"Analytics"</div>
                <div>{move || {
                    let (total, unique, _) = summary.get();
                    format!("{} mounts, {} components", total, unique)
                }}</div>
            </div>
        }.into_any()
    } else {
        view! { <div class="analytics-badge-hidden"></div> }.into_any()
    };

    content
}

/// Format a timestamp for display
pub fn format_timestamp(timestamp: u64) -> String {
    timestamp.to_string()
}
