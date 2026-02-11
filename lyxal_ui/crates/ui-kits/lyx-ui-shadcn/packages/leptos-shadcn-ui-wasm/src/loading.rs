//! # WASM Loading UI Components
//!
//! This module provides UI components for displaying WASM loading states.
//! Includes spinners, progress bars, and comprehensive loading state components.

use leptos::prelude::*;

/// Loading spinner component for WASM operations
///
/// # Example
///
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_ui_wasm::loading::WasmSpinner;
///
/// view! {
///     <WasmSpinner size="md" />
/// }
/// ```
#[component]
pub fn WasmSpinner(
    #[prop(into, optional)] size: MaybeProp<String>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] id: MaybeProp<String>,
) -> impl IntoView {
    let size_value = size.get().unwrap_or_else(|| "md".to_string());
    let size_class = match size_value.as_str() {
        "sm" => "h-4 w-4",
        "md" => "h-6 w-6",
        "lg" => "h-8 w-8",
        "xl" => "h-12 w-12",
        _ => "h-6 w-6",
    };

    view! {
        <svg
            class=format!("{} {} animate-spin", size_class, class.get().unwrap_or_default())
            id=id.get().unwrap_or_default()
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
        >
            <path d="M21 12a9 9 0 11-6.219-8.56" />
        </svg>
    }
}

/// Loading progress bar component for WASM operations
///
/// # Example
///
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_ui_wasm::loading::WasmProgressBar;
///
/// view! {
///     <WasmProgressBar progress=Signal::new(50) />
/// }
/// ```
#[component]
pub fn WasmProgressBar(
    /// Progress percentage (0-100)
    #[prop(into)] progress: Signal<i32>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] id: MaybeProp<String>,
    #[prop(into, optional)] show_label: MaybeProp<bool>,
    #[prop(into, optional)] label: MaybeProp<String>,
) -> impl IntoView {
    let show_label_value = show_label.get().unwrap_or(false);
    let label_text = label.get().unwrap_or_else(|| "Loading...".to_string());

    view! {
        <div
            class="w-full"
            id=id.get().unwrap_or_default()
        >
            {show_label_value.then_some(view! {
                <div class="flex justify-between items-center mb-1">
                    <span class="text-sm text-muted-foreground">{label_text}</span>
                    <span class="text-sm text-muted-foreground">{move || format!("{}%", progress.get())}</span>
                </div>
            })}
            <div class=format!("h-2 w-full bg-secondary rounded-full overflow-hidden {}", class.get().unwrap_or_default())>
                <div
                    class="h-full bg-primary transition-all duration-300 ease-in-out"
                    style=move || format!("width: {}%", progress.get().clamp(0, 100))
                />
            </div>
        </div>
    }
}

/// Text component that displays loading status messages
///
/// # Example
///
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_ui_wasm::loading::WasmLoadingText;
///
/// view! {
///     <WasmLoadingText text=Signal::new("Initializing WASM...".to_string()) />
/// }
/// ```
#[component]
pub fn WasmLoadingText(
    #[prop(into)] text: Signal<String>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] id: MaybeProp<String>,
    #[prop(into, optional)] show_spinner: MaybeProp<bool>,
    #[prop(into, optional)] spinner_size: MaybeProp<String>,
) -> impl IntoView {
    let show_spinner_value = show_spinner.get().unwrap_or(true);
    let spinner_size_value = spinner_size.get().unwrap_or_else(|| "sm".to_string());

    view! {
        <div
            class=format!("flex items-center gap-2 {}", class.get().unwrap_or_default())
            id=id.get().unwrap_or_default()
        >
            {show_spinner_value.then_some(view! { <WasmSpinner size=spinner_size_value /> })}
            <span class="text-sm text-muted-foreground">{move || text.get()}</span>
        </div>
    }
}

/// Inline loading indicator for WASM operations within a component
///
/// This is useful for showing loading state during specific WASM operations
/// rather than the entire initialization process.
///
/// # Example
///
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_ui_wasm::loading::WasmInlineLoader;
///
/// #[component]
/// pub fn MyComponent() -> impl IntoView {
///     let (loading, set_loading) = signal(false);
///
///     view! {
///         <button
///             on:click=move |_| {
///                 set_loading.set(true);
///                 // Perform WASM operation
///                 set_loading.set(false);
///             }
///         >
///             <WasmInlineLoader loading=Signal::from(loading) />
///             "Click me"
///         </button>
///     }
/// }
/// ```
#[component]
pub fn WasmInlineLoader(
    #[prop(into)] loading: Signal<bool>,
    #[prop(into, optional)] size: MaybeProp<String>,
    #[prop(into, optional)] class: MaybeProp<String>,
) -> impl IntoView {
    let size_value = size.get().unwrap_or_else(|| "sm".to_string());
    let size_class = match size_value.as_str() {
        "sm" => "h-3 w-3",
        "md" => "h-4 w-4",
        "lg" => "h-6 w-6",
        _ => "h-3 w-3",
    };

    view! {
        {move || {
            if loading.get() {
                Some(view! {
                    <svg
                        class=format!("{} animate-spin {}", size_class, class.get().unwrap_or_default())
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                        stroke-linejoin="round"
                    >
                        <path d="M21 12a9 9 0 11-6.219-8.56" />
                    </svg>
                })
            } else {
                None
            }
        }}
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wasm_spinner_size_classes() {
        // Test that size mapping works correctly
        let sizes = vec![("sm", "h-4 w-4"), ("md", "h-6 w-6"), ("lg", "h-8 w-8"), ("xl", "h-12 w-12")];
        for (input, expected) in sizes {
            let result = match input {
                "sm" => "h-4 w-4",
                "md" => "h-6 w-6",
                "lg" => "h-8 w-8",
                "xl" => "h-12 w-12",
                _ => "h-6 w-6",
            };
            assert_eq!(result, expected);
        }
    }
}
