//! Lazy loading system for shadcn/ui Leptos components
//!
//! This module provides lazy loading capabilities to reduce initial bundle size
//! by loading components only when they're needed.
//!
//! # Code Splitting
//!
//! This module uses Leptos's `#[lazy]` macro to enable component-level code splitting.
//! Each lazy-loaded component is compiled into a separate WASM chunk that is loaded
//! on-demand when the component is first rendered.

use leptos::prelude::*;
use leptos::html::ElementChild;
use leptos::task::spawn_local;
use leptos::lazy;
use leptos_shadcn_error_boundary::{
    ErrorContext, ErrorSeverity, RecoverySuggestion, RichErrorFallback,
};
use std::collections::HashMap;
use std::sync::Arc;
use std::sync::Mutex;

/// Lazy component loader that manages dynamic imports
#[derive(Clone)]
pub struct LazyComponentLoader {
    components: Arc<Mutex<HashMap<String, ComponentLoader>>>,
}

/// Component loader function type
pub type ComponentLoader = Box<dyn Fn() -> Result<View<()>, String> + Send + Sync>;

impl LazyComponentLoader {
    /// Create a new lazy component loader
    pub fn new() -> Self {
        Self {
            components: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    /// Register a component for lazy loading
    pub fn register_component<F>(&self, name: &str, loader: F)
    where
        F: Fn() -> Result<View<()>, String> + Send + Sync + 'static,
    {
        let mut components = self.components.lock().unwrap();
        components.insert(name.to_string(), Box::new(loader));
    }

    /// Load a component by name
    pub fn load_component(&self, name: &str) -> Result<View<()>, String> {
        let components = self.components.lock().unwrap();
        if let Some(loader) = components.get(name) {
            loader()
        } else {
            Err(format!("Component '{}' not found", name))
        }
    }

    /// Check if a component is registered
    pub fn has_component(&self, name: &str) -> bool {
        let components = self.components.lock().unwrap();
        components.contains_key(name)
    }

    /// Get all registered component names
    pub fn registered_components(&self) -> Vec<String> {
        let components = self.components.lock().unwrap();
        components.keys().cloned().collect()
    }
}

impl Default for LazyComponentLoader {
    fn default() -> Self {
        Self::new()
    }
}

// =============================================================================
// Code-Split Components
// =============================================================================
// These components use the #[lazy] macro to enable code splitting.
// Each component will be compiled into a separate WASM chunk that is
// loaded on-demand when first accessed.

/// Lazy-loaded button component
/// This component is compiled into a separate WASM chunk
#[lazy]
async fn lazy_button_component() -> Result<View<()>, String> {
    Ok(view! {
        <div class="lazy-demo-component">
            <button class="lazy-demo-button">"Lazy Loaded Button"</button>
        </div>
    })
}

/// Lazy-loaded card component
/// This component is compiled into a separate WASM chunk
#[lazy]
async fn lazy_card_component() -> Result<View<()>, String> {
    Ok(view! {
        <div class="lazy-demo-card">
            <h3>"Lazy Loaded Card"</h3>
            <p>"This card was loaded on-demand from a separate WASM chunk."</p>
        </div>
    })
}

/// Lazy-loaded input component
/// This component is compiled into a separate WASM chunk
#[lazy]
async fn lazy_input_component() -> Result<View<()>, String> {
    Ok(view! {
        <div class="lazy-demo-input">
            <input type="text" placeholder="Lazy loaded input..." />
            <p>"This input component was loaded from its own chunk."</p>
        </div>
    })
}

/// Lazy-loaded alert component
/// This component is compiled into a separate WASM chunk
#[lazy]
async fn lazy_alert_component() -> Result<View<()>, String> {
    Ok(view! {
        <div class="lazy-demo-alert">
            <div class="alert-content">
                <strong>"Lazy Alert!"</strong>
                <p>"This alert component was loaded on-demand."</p>
            </div>
        </div>
    })
}

/// Lazy-loaded form component (larger component for demonstration)
/// This component is compiled into a separate WASM chunk
#[lazy]
async fn lazy_form_component() -> Result<View<()>, String> {
    Ok(view! {
        <div class="lazy-demo-form">
            <h3>"Lazy Loaded Form"</h3>
            <form on:submit=|e| { e.prevent_default(); }>
                <div class="form-field">
                    <label>"Username"</label>
                    <input type="text" placeholder="Enter username" />
                </div>
                <div class="form-field">
                    <label>"Email"</label>
                    <input type="email" placeholder="Enter email" />
                </div>
                <button type="submit">"Submit"</button>
            </form>
            <p>"This form component demonstrates lazy loading of larger components."</p>
        </div>
    })
}

// =============================================================================
// Lazy Component Wrapper
// =============================================================================

/// Lazy component wrapper that loads components on demand
#[component]
pub fn LazyComponent(
    #[prop(into)] name: String,
    #[prop(optional)] fallback: Option<Box<dyn Fn() -> AnyView + Send + Sync>>,
    #[prop(optional)] error_fallback: Option<Box<dyn Fn(String) -> AnyView + Send + Sync>>,
) -> impl IntoView {
    let loader = use_context::<LazyComponentLoader>()
        .expect("LazyComponentLoader not found in context");
    
    let (component, set_component) = signal(None::<Result<View<()>, String>>);
    let (loading, set_loading) = signal(true);
    let (error, set_error) = signal(None::<String>);

    // Track if component is mounted for async task cleanup
    let (is_mounted, set_is_mounted) = signal(true);

    // Load component when name changes
    Effect::new(move |_| {
        let name = name.clone();
        let loader = loader.clone();
        let is_mounted = is_mounted.clone();

        spawn_local(async move {
            set_loading.set(true);
            set_error.set(None);

            // Simulate async loading
            let result = loader.load_component(&name);

            // Only update if component is still mounted
            if is_mounted.get() {
                set_component.set(Some(result.clone()));
                set_loading.set(false);

                if let Err(err) = result {
                    set_error.set(Some(err));
                }
            }
        });
    });

    // Set flag to false on cleanup to prevent async task from updating state
    on_cleanup(move || {
        set_is_mounted.set(false);
    });

    // Render based on state
    move || {
        if loading.get() {
            // Show fallback while loading
            if let Some(fallback_fn) = &fallback {
                fallback_fn()
            } else {
                view! {
                    <div class="lazy-loading-fallback">
                        <div class="loading-spinner"></div>
                        <p>"Loading component..."</p>
                    </div>
                }.into_any()
            }
        } else if let Some(Ok(comp)) = component.get() {
            // Component loaded successfully
            comp.into_any()
        } else if let Some(err) = error.get() {
            // Component failed to load - use RichErrorFallback with severity indicators
            // and recovery suggestions from the error-boundary package
            if let Some(error_fn) = &error_fallback {
                error_fn(err)
            } else {
                let error_context = ErrorContext::new(format!("Failed to load component: {}", err))
                    .with_severity(ErrorSeverity::Error)
                    .with_recovery_suggestion(RecoverySuggestion {
                        action: "Retry loading the component".to_string(),
                        explanation: Some("The component may have failed to load due to a network issue. \
                            Clicking retry will attempt to load the component again.".to_string()),
                    })
                    .with_recovery_suggestion(RecoverySuggestion {
                        action: "Refresh the page".to_string(),
                        explanation: Some("If retrying doesn't work, try refreshing the entire page.".to_string()),
                    });

                let retry_loading = move |_| {
                    set_loading.set(true);
                    set_error.set(None);
                };

                view! {
                    <RichErrorFallback error_context={error_context.clone()}>
                        <div slot="error-actions" class="lazy-loading-error-actions">
                            <button
                                class="error-retry"
                                on:click=retry_loading
                            >
                                "Retry"
                            </button>
                        </div>
                    </RichErrorFallback>
                }.into_any()
            }
        } else {
            // No component loaded yet
            view! { <div></div> }.into_any()
        }
    }
}

/// Hook for lazy loading components with proper cleanup
pub fn use_lazy_component(name: &str) -> (ReadSignal<bool>, ReadSignal<Option<Result<View<()>, String>>>, WriteSignal<bool>) {
    let (loading, set_loading) = signal(false);
    let (component, set_component) = signal(None::<Result<View<()>, String>>);
    let (is_mounted, set_is_mounted) = signal(true);

    let loader = use_context::<LazyComponentLoader>()
        .expect("LazyComponentLoader not found in context");

    let name = name.to_string();
    let is_mounted_for_load = is_mounted.clone();
    let load = move || {
        set_loading.set(true);

        spawn_local(async move {
            let result = loader.load_component(&name);
            // Only update if component is still mounted
            if is_mounted_for_load.get() {
                set_component.set(Some(result));
                set_loading.set(false);
            }
        });
    };

    // Set up cleanup
    on_cleanup(move || {
        set_is_mounted.set(false);
    });

    (loading, component, set_loading)
}

/// Component bundle analyzer for optimization
pub struct BundleAnalyzer;

impl BundleAnalyzer {
    /// Analyze component usage and provide optimization suggestions
    pub fn analyze_usage(components: &[String]) -> BundleAnalysis {
        let mut analysis = BundleAnalysis::new();
        
        // Analyze component categories
        let form_components = ["input", "label", "checkbox", "radio-group", "select", "textarea", "form"];
        let layout_components = ["card", "separator", "skeleton", "tabs"];
        let interactive_components = ["button", "checkbox", "radio-group", "select", "switch", "tabs"];
        
        let form_count = components.iter().filter(|c| form_components.contains(&c.as_str())).count();
        let layout_count = components.iter().filter(|c| layout_components.contains(&c.as_str())).count();
        let interactive_count = components.iter().filter(|c| interactive_components.contains(&c.as_str())).count();
        
        analysis.form_components = form_count;
        analysis.layout_components = layout_count;
        analysis.interactive_components = interactive_count;
        analysis.total_components = components.len();
        
        // Generate recommendations
        if form_count > 4 {
            analysis.recommendations.push("Consider lazy loading form components to reduce initial bundle size".to_string());
        }
        
        if layout_count > 3 {
            analysis.recommendations.push("Layout components can be loaded on demand for better performance".to_string());
        }
        
        if interactive_count > 5 {
            analysis.recommendations.push("Interactive components benefit from lazy loading for better UX".to_string());
        }
        
        analysis
    }
}

/// Bundle analysis results
#[derive(Debug, Clone)]
pub struct BundleAnalysis {
    pub form_components: usize,
    pub layout_components: usize,
    pub interactive_components: usize,
    pub total_components: usize,
    pub recommendations: Vec<String>,
}

impl BundleAnalysis {
    fn new() -> Self {
        Self {
            form_components: 0,
            layout_components: 0,
            interactive_components: 0,
            total_components: 0,
            recommendations: Vec::new(),
        }
    }
}

mod tests {
    use super::*;

    #[test]
    fn test_lazy_component_loader() {
        let loader = LazyComponentLoader::new();
        
        // Register a test component
        loader.register_component("test", || {
            Ok(View::new(()))
        });
        
        assert!(loader.has_component("test"));
        assert!(!loader.has_component("nonexistent"));
        
        let components = loader.registered_components();
        assert!(components.contains(&"test".to_string()));
    }

    #[test]
    fn test_bundle_analyzer() {
        let components = vec!["button".to_string(), "input".to_string(), "card".to_string()];
        let analysis = BundleAnalyzer::analyze_usage(&components);

        assert_eq!(analysis.total_components, 3);
        assert_eq!(analysis.form_components, 1);
        assert_eq!(analysis.layout_components, 1);
        assert_eq!(analysis.interactive_components, 1);
    }
}

// =============================================================================
// Public Exports
// =============================================================================

// Export the code-split lazy component functions for use in examples
pub use lazy_button_component;
pub use lazy_card_component;
pub use lazy_input_component;
pub use lazy_alert_component;
pub use lazy_form_component;
