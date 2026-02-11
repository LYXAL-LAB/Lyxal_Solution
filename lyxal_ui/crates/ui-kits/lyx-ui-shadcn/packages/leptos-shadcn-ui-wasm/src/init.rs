//! # WASM Initialization and State Management
//!
//! This module provides comprehensive WASM binding initialization with proper state management,
//! loading states, error handling, and initialization status tracking for Leptos applications.

use leptos::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use wasm_bindgen::JsValue;

/// WASM initialization state
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum WasmInitState {
    /// Initial state before initialization begins
    #[default]
    NotStarted,
    /// Initialization is in progress
    Initializing,
    /// Initialization completed successfully
    Ready,
    /// Initialization failed
    Failed,
}

/// Detailed WASM initialization status with context
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WasmInitStatus {
    /// Current state of WASM initialization
    pub state: WasmInitState,
    /// Human-readable status message
    pub message: String,
    /// Progress percentage (0-100) for loading operations
    pub progress: u8,
    /// Error details if state is Failed
    pub error: Option<WasmError>,
    /// Timestamp of last state change
    pub timestamp: f64,
}

impl Default for WasmInitStatus {
    fn default() -> Self {
        Self {
            state: WasmInitState::NotStarted,
            message: "WASM initialization not started".to_string(),
            progress: 0,
            error: None,
            timestamp: js_timestamp(),
        }
    }
}

/// WASM error with detailed context for debugging
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WasmError {
    /// Error category for easier handling
    pub category: WasmErrorCategory,
    /// Human-readable error message
    pub message: String,
    /// Technical details for debugging
    pub details: Option<String>,
    /// Stack trace if available
    pub stack: Option<String>,
    /// Additional context
    pub context: std::collections::HashMap<String, String>,
}

impl std::fmt::Display for WasmError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "[{:?}] {}", self.category, self.message)
    }
}

impl std::error::Error for WasmError {}

/// Error category for WASM operations
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum WasmErrorCategory {
    /// Error during WASM compilation/instantiation
    Compilation,
    /// Error during WASM binding initialization
    Binding,
    /// Error during state management setup
    State,
    /// Error during feature detection
    FeatureDetection,
    /// Error during panic handler setup
    PanicHandler,
    /// Error during console logging setup
    Console,
    /// Unknown or other errors
    Other,
}

impl From<JsValue> for WasmError {
    fn from(js_value: JsValue) -> Self {
        Self {
            category: WasmErrorCategory::Binding,
            message: format!("JavaScript error: {:?}", js_value),
            details: js_value.as_string(),
            stack: None,
            context: std::collections::HashMap::new(),
        }
    }
}

/// Configuration for WASM initialization
#[derive(Clone)]
pub struct WasmInitConfig {
    /// Enable verbose logging during initialization
    pub verbose: bool,
    /// Custom panic message
    pub panic_message: Option<String>,
    /// Callback invoked when initialization starts
    pub on_start: Option<WasmCallback>,
    /// Callback invoked when initialization completes
    pub on_ready: Option<WasmCallback>,
    /// Callback invoked when initialization fails
    pub on_error: Option<WasmErrorCallback>,
    /// Callback invoked on progress updates
    pub on_progress: Option<WasmProgressCallback>,
}

impl Default for WasmInitConfig {
    fn default() -> Self {
        Self {
            verbose: false,
            panic_message: None,
            on_start: None,
            on_ready: None,
            on_error: None,
            on_progress: None,
        }
    }
}

/// Callback type for WASM initialization events
pub type WasmCallback = Arc<dyn Fn() + Send + Sync + 'static>;

/// Callback type for WASM errors
pub type WasmErrorCallback = Arc<dyn Fn(WasmError) + Send + Sync + 'static>;

/// Callback type for progress updates
pub type WasmProgressCallback = Arc<dyn Fn(u8) + Send + Sync + 'static>;

/// Global WASM initialization state manager
#[derive(Clone)]
pub struct WasmInitManager {
    /// Current initialization status
    status: ArcRwSignal<WasmInitStatus>,
    /// Configuration for initialization
    config: ArcRwSignal<WasmInitConfig>,
    /// Whether panic hook has been set up
    panic_hook_setup: Arc<AtomicBool>,
}

impl WasmInitManager {
    /// Create a new WASM initialization manager
    pub fn new() -> Self {
        Self {
            status: ArcRwSignal::new(WasmInitStatus::default()),
            config: ArcRwSignal::new(WasmInitConfig::default()),
            panic_hook_setup: Arc::new(AtomicBool::new(false)),
        }
    }

    /// Provide the WASM init manager as context
    pub fn provide_context(&self) {
        provide_context(self.clone());
    }

    /// Get the WASM init manager from context
    pub fn from_context() -> Option<Self> {
        use_context()
    }

    /// Get the current initialization status
    pub fn status(&self) -> ArcRwSignal<WasmInitStatus> {
        self.status.clone()
    }

    /// Get the current initialization state
    pub fn state(&self) -> WasmInitState {
        self.status.get().state
    }

    /// Check if WASM is ready
    pub fn is_ready(&self) -> bool {
        self.state() == WasmInitState::Ready
    }

    /// Check if WASM is initializing
    pub fn is_initializing(&self) -> bool {
        self.state() == WasmInitState::Initializing
    }

    /// Check if WASM initialization has failed
    pub fn has_failed(&self) -> bool {
        self.state() == WasmInitState::Failed
    }

    /// Initialize WASM with the given configuration
    ///
    /// This function:
    /// 1. Sets up the panic hook for better error messages
    /// 2. Performs feature detection
    /// 3. Sets up console logging
    /// 4. Updates the initialization state
    pub fn init(&self, config: WasmInitConfig) -> Result<(), WasmError> {
        // Update configuration
        self.config.set(config.clone());

        // Check if already initialized
        if self.state() == WasmInitState::Ready {
            if config.verbose {
                log("WASM already initialized");
            }
            return Ok(());
        }

        // Mark initialization as started
        self.update_state(WasmInitStatus {
            state: WasmInitState::Initializing,
            message: "Initializing WASM...".to_string(),
            progress: 0,
            error: None,
            timestamp: js_timestamp(),
        });

        // Invoke start callback
        if let Some(callback) = &config.on_start {
            callback();
        }

        // Set up panic hook if not already set
        if !self.panic_hook_setup.load(Ordering::Relaxed) {
            self.setup_panic_hook(&config)?;
            self.panic_hook_setup.store(true, Ordering::Relaxed);
        }

        // Perform feature detection
        self.detect_features(&config)?;

        // Log successful initialization
        if config.verbose {
            log("WASM initialization completed successfully");
        }

        // Mark as ready
        self.update_state(WasmInitStatus {
            state: WasmInitState::Ready,
            message: "WASM ready".to_string(),
            progress: 100,
            error: None,
            timestamp: js_timestamp(),
        });

        // Invoke ready callback
        if let Some(callback) = &config.on_ready {
            callback();
        }

        Ok(())
    }

    /// Quick initialization with default configuration
    pub fn init_default(&self) -> Result<(), WasmError> {
        self.init(WasmInitConfig::default())
    }

    /// Setup panic hook for better error messages
    fn setup_panic_hook(&self, _config: &WasmInitConfig) -> Result<(), WasmError> {
        self.update_progress(10, "Setting up panic hook...");

        // Use the console_error_panic_hook for better error messages in browser
        console_error_panic_hook::set_once();

        Ok(())
    }

    /// Detect browser features and capabilities
    fn detect_features(&self, config: &WasmInitConfig) -> Result<(), WasmError> {
        self.update_progress(30, "Detecting browser features...");

        let window = web_sys::window()
            .ok_or_else(|| WasmError {
                category: WasmErrorCategory::FeatureDetection,
                message: "Could not access window object".to_string(),
                details: None,
                stack: None,
                context: std::collections::HashMap::new(),
            })?;

        // Check for required APIs
        let _performance = window.performance()
            .ok_or_else(|| WasmError {
                category: WasmErrorCategory::FeatureDetection,
                message: "Performance API not available".to_string(),
                details: None,
                stack: None,
                context: std::collections::HashMap::new(),
            })?;

        // Log window availability if verbose
        if config.verbose {
            log("Window and Performance APIs available");
        }

        self.update_progress(50, "Feature detection complete");
        Ok(())
    }

    /// Update the initialization state
    fn update_state(&self, new_status: WasmInitStatus) {
        self.status.set(new_status);
    }

    /// Update progress and invoke progress callback if set
    fn update_progress(&self, progress: u8, message: &str) {
        let mut current = self.status.get();
        current.progress = progress;
        current.message = message.to_string();
        current.timestamp = js_timestamp();
        self.status.set(current.clone());

        // Invoke progress callback
        let config = self.config.get();
        if let Some(callback) = &config.on_progress {
            callback(progress);
        }
    }

    /// Handle an initialization error
    pub fn handle_error(&self, error: WasmError) {
        log_error(&error.message);

        self.update_state(WasmInitStatus {
            state: WasmInitState::Failed,
            message: format!("Initialization failed: {}", error),
            progress: self.status.get().progress,
            error: Some(error.clone()),
            timestamp: js_timestamp(),
        });

        // Invoke error callback
        let config = self.config.get();
        if let Some(callback) = &config.on_error {
            callback(error);
        }
    }

    /// Reset the initialization state (useful for retry)
    pub fn reset(&self) {
        self.status.set(WasmInitStatus::default());
        self.panic_hook_setup.store(false, Ordering::Relaxed);
    }

    /// Retry initialization
    pub fn retry(&self) -> Result<(), WasmError> {
        let config = self.config.get();
        self.reset();
        self.init(config.clone())
    }
}

impl Default for WasmInitManager {
    fn default() -> Self {
        Self::new()
    }
}

/// Get current timestamp from JavaScript
pub fn js_timestamp() -> f64 {
    web_sys::window()
        .and_then(|w| w.performance())
        .map(|p| p.now())
        .unwrap_or(0.0)
}

/// Log a message to the browser console
pub fn log(message: &str) {
    web_sys::console::log_1(&message.into());
}

/// Log an error to the browser console
pub fn log_error(message: &str) {
    web_sys::console::error_1(&message.into());
}

/// Log a warning to the browser console
pub fn log_warn(message: &str) {
    web_sys::console::warn_1(&message.into());
}

/// Convenience function to initialize WASM with minimal boilerplate
///
/// # Example
///
/// ```rust
/// use leptos_shadcn_ui_wasm::init::init_wasm;
///
/// #[wasm_bindgen(start)]
/// pub fn main() {
///     init_wasm().expect("Failed to initialize WASM");
///     // Your app initialization code here
/// }
/// ```
pub fn init_wasm() -> Result<(), WasmError> {
    let manager = WasmInitManager::new();
    manager.init_default()
}

/// Convenience function to initialize WASM with a custom configuration
///
/// # Example
///
/// ```rust
/// use leptos_shadcn_ui_wasm::init::{init_wasm_with_config, WasmInitConfig};
///
/// #[wasm_bindgen(start)]
/// pub fn main() {
///     let config = WasmInitConfig {
///         verbose: true,
///         ..Default::default()
///     };
///     init_wasm_with_config(config).expect("Failed to initialize WASM");
/// }
/// ```
pub fn init_wasm_with_config(config: WasmInitConfig) -> Result<(), WasmError> {
    let manager = WasmInitManager::new();
    manager.init(config)
}

/// Initialize WASM and provide the manager as Leptos context
///
/// This is the recommended way to initialize WASM in Leptos applications
/// as it makes the initialization status available throughout your app.
///
/// # Example
///
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_ui_wasm::init::provide_wasm_init;
///
/// #[component]
/// pub fn App() -> impl IntoView {
///     provide_wasm_init();
///     // Your app code here
/// }
/// ```
pub fn provide_wasm_init() {
    let manager = WasmInitManager::new();
    manager.provide_context();
    let _ = manager.init_default();
}

/// Initialize WASM with custom config and provide as Leptos context
///
/// # Example
///
/// ```rust
/// use leptos::prelude::*;
/// use leptos_shadcn_ui_wasm::init::{provide_wasm_init_with_config, WasmInitConfig};
///
/// #[component]
/// pub fn App() -> impl IntoView {
///     let config = WasmInitConfig {
///         verbose: true,
///         ..Default::default()
///     };
///     provide_wasm_init_with_config(config);
///     // Your app code here
/// }
/// ```
pub fn provide_wasm_init_with_config(config: WasmInitConfig) {
    let manager = WasmInitManager::new();
    manager.provide_context();
    let _ = manager.init(config);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_init_state_default() {
        let state = WasmInitState::default();
        assert_eq!(state, WasmInitState::NotStarted);
    }

    #[test]
    fn test_init_status_default() {
        let status = WasmInitStatus::default();
        assert_eq!(status.state, WasmInitState::NotStarted);
        assert_eq!(status.progress, 0);
        assert!(status.error.is_none());
    }

    #[test]
    fn test_manager_creation() {
        let manager = WasmInitManager::new();
        assert_eq!(manager.state(), WasmInitState::NotStarted);
        assert!(!manager.is_ready());
        assert!(!manager.is_initializing());
        assert!(!manager.has_failed());
    }

    #[test]
    fn test_config_default() {
        let config = WasmInitConfig::default();
        assert!(!config.verbose);
        assert!(config.panic_message.is_none());
        assert!(config.on_start.is_none());
        assert!(config.on_ready.is_none());
        assert!(config.on_error.is_none());
        assert!(config.on_progress.is_none());
    }

    #[test]
    fn test_wasm_error_display() {
        let error = WasmError {
            category: WasmErrorCategory::Binding,
            message: "Test error".to_string(),
            details: None,
            stack: None,
            context: std::collections::HashMap::new(),
        };
        let display = format!("{}", error);
        assert!(display.contains("Binding"));
        assert!(display.contains("Test error"));
    }
}
