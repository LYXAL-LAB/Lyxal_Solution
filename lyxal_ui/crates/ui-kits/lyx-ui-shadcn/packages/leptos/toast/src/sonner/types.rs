//! Types and enums for the Sonner toast component
//!
//! This module contains the core types, enums, and data structures
//! used by the Sonner toast system, including enhanced error metadata
//! and recovery hints for debugging.

use leptos::prelude::*;
use std::time::{Duration, Instant};
use std::collections::HashMap;

/// Toast position variants
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ToastPosition {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
    TopCenter,
    BottomCenter,
}

impl Default for ToastPosition {
    fn default() -> Self {
        ToastPosition::TopRight
    }
}

impl From<String> for ToastPosition {
    fn from(s: String) -> Self {
        match s.as_str() {
            "top-left" => ToastPosition::TopLeft,
            "top-right" => ToastPosition::TopRight,
            "bottom-left" => ToastPosition::BottomLeft,
            "bottom-right" => ToastPosition::BottomRight,
            "top-center" => ToastPosition::TopCenter,
            "bottom-center" => ToastPosition::BottomCenter,
            _ => ToastPosition::TopRight,
        }
    }
}

/// Toast theme variants
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ToastTheme {
    Light,
    Dark,
    Auto,
}

impl Default for ToastTheme {
    fn default() -> Self {
        ToastTheme::Auto
    }
}

impl From<String> for ToastTheme {
    fn from(s: String) -> Self {
        match s.as_str() {
            "light" => ToastTheme::Light,
            "dark" => ToastTheme::Dark,
            "auto" => ToastTheme::Auto,
            _ => ToastTheme::Auto,
        }
    }
}

/// Toast variant types
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ToastVariant {
    Default,
    Success,
    Error,
    Warning,
    Info,
    Loading,
}

impl Default for ToastVariant {
    fn default() -> Self {
        ToastVariant::Default
    }
}

/// Toast action definition
#[derive(Debug, Clone)]
pub struct ToastAction {
    pub label: String,
    pub action: Callback<()>,
    /// Whether this is a primary action
    pub primary: bool,
    /// Optional icon for the action
    pub icon: Option<String>,
}

impl ToastAction {
    pub fn new(label: String, action: Callback<()>) -> Self {
        Self {
            label,
            action,
            primary: false,
            icon: None,
        }
    }

    pub fn with_primary(mut self) -> Self {
        self.primary = true;
        self
    }

    pub fn with_icon(mut self, icon: String) -> Self {
        self.icon = Some(icon);
        self
    }
}

/// Error metadata for toast notifications
#[derive(Debug, Clone)]
pub struct ToastErrorMetadata {
    /// Error code for categorization
    pub error_code: Option<String>,
    /// Error severity level
    pub severity: Option<String>,
    /// Source component or module
    pub source: Option<String>,
    /// Error stack trace (for debugging)
    pub stack_trace: Option<String>,
    /// Request ID (for API errors)
    pub request_id: Option<String>,
    /// Endpoint URL (for API errors)
    pub endpoint: Option<String>,
    /// HTTP status code (for API errors)
    pub status_code: Option<u16>,
    /// Additional context metadata
    pub context: HashMap<String, String>,
}

impl ToastErrorMetadata {
    pub fn new() -> Self {
        Self {
            error_code: None,
            severity: None,
            source: None,
            stack_trace: None,
            request_id: None,
            endpoint: None,
            status_code: None,
            context: HashMap::new(),
        }
    }

    pub fn with_error_code(mut self, code: String) -> Self {
        self.error_code = Some(code);
        self
    }

    pub fn with_severity(mut self, severity: String) -> Self {
        self.severity = Some(severity);
        self
    }

    pub fn with_source(mut self, source: String) -> Self {
        self.source = Some(source);
        self
    }

    pub fn with_stack_trace(mut self, trace: String) -> Self {
        self.stack_trace = Some(trace);
        self
    }

    pub fn with_request_id(mut self, id: String) -> Self {
        self.request_id = Some(id);
        self
    }

    pub fn with_endpoint(mut self, endpoint: String) -> Self {
        self.endpoint = Some(endpoint);
        self
    }

    pub fn with_status_code(mut self, code: u16) -> Self {
        self.status_code = Some(code);
        self
    }

    pub fn with_context(mut self, key: String, value: String) -> Self {
        self.context.insert(key, value);
        self
    }

    pub fn with_context_map(mut self, map: HashMap<String, String>) -> Self {
        self.context.extend(map);
        self
    }
}

impl Default for ToastErrorMetadata {
    fn default() -> Self {
        Self::new()
    }
}

/// Recovery hint for toast error notifications
#[derive(Debug, Clone)]
pub struct ToastRecoveryHint {
    /// User-friendly action to take
    pub action: String,
    /// Detailed explanation
    pub explanation: Option<String>,
    /// Whether the action can be performed automatically
    pub automatic: bool,
    /// Callback to perform the recovery action
    pub callback: Option<Callback<()>>,
}

impl ToastRecoveryHint {
    pub fn new(action: String) -> Self {
        Self {
            action,
            explanation: None,
            automatic: false,
            callback: None,
        }
    }

    pub fn with_explanation(mut self, explanation: String) -> Self {
        self.explanation = Some(explanation);
        self
    }

    pub fn with_automatic(mut self) -> Self {
        self.automatic = true;
        self
    }

    pub fn with_callback(mut self, callback: Callback<()>) -> Self {
        self.callback = Some(callback);
        self
    }
}

/// Toast data structure with enhanced error context
#[derive(Debug, Clone)]
pub struct ToastData {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub variant: ToastVariant,
    pub duration: Option<Duration>,
    pub position: ToastPosition,
    pub theme: ToastTheme,
    pub actions: Vec<ToastAction>,
    pub progress: Option<f64>,
    pub created_at: Instant,
    /// Error metadata (for error toasts)
    pub error_metadata: Option<ToastErrorMetadata>,
    /// Recovery hints (for error toasts)
    pub recovery_hints: Vec<ToastRecoveryHint>,
    /// Whether this toast is dismissible by user
    pub closeable: bool,
    /// Custom CSS classes
    pub class_name: Option<String>,
}

impl ToastData {
    pub fn new(title: String) -> Self {
        Self {
            id: uuid::Uuid::new_v4().to_string(),
            title,
            description: None,
            variant: ToastVariant::Default,
            duration: Some(Duration::from_millis(4000)),
            position: ToastPosition::TopRight,
            theme: ToastTheme::Auto,
            actions: Vec::new(),
            progress: None,
            created_at: Instant::now(),
            error_metadata: None,
            recovery_hints: Vec::new(),
            closeable: true,
            class_name: None,
        }
    }

    /// Set toast variant
    pub fn with_variant(mut self, variant: ToastVariant) -> Self {
        self.variant = variant;
        self
    }

    /// Set toast description
    pub fn with_description(mut self, description: String) -> Self {
        self.description = Some(description);
        self
    }

    /// Set toast duration
    pub fn with_duration(mut self, duration: Duration) -> Self {
        self.duration = Some(duration);
        self
    }

    /// Set toast position
    pub fn with_position(mut self, position: ToastPosition) -> Self {
        self.position = position;
        self
    }

    /// Set toast theme
    pub fn with_theme(mut self, theme: ToastTheme) -> Self {
        self.theme = theme;
        self
    }

    /// Add an action to the toast
    pub fn with_action(mut self, action: ToastAction) -> Self {
        self.actions.push(action);
        self
    }

    /// Set progress value (for loading toasts)
    pub fn with_progress(mut self, progress: f64) -> Self {
        self.progress = Some(progress);
        self
    }

    /// Set error metadata (for error toasts)
    pub fn with_error_metadata(mut self, metadata: ToastErrorMetadata) -> Self {
        self.error_metadata = Some(metadata);
        self
    }

    /// Add a recovery hint (for error toasts)
    pub fn with_recovery_hint(mut self, hint: ToastRecoveryHint) -> Self {
        self.recovery_hints.push(hint);
        self
    }

    /// Set whether the toast can be closed
    pub fn with_closeable(mut self, closeable: bool) -> Self {
        self.closeable = closeable;
        self
    }

    /// Set custom CSS class
    pub fn with_class(mut self, class: String) -> Self {
        self.class_name = Some(class);
        self
    }

    /// Create an error toast with enhanced context
    pub fn error_with_context(
        title: String,
        description: Option<String>,
        error_metadata: ToastErrorMetadata,
    ) -> Self {
        Self::new(title)
            .with_variant(ToastVariant::Error)
            .with_description(description.unwrap_or_else(|| "An error occurred".to_string()))
            .with_error_metadata(error_metadata)
    }

    /// Create a success toast
    pub fn success(title: String, description: Option<String>) -> Self {
        Self::new(title)
            .with_variant(ToastVariant::Success)
            .with_description(description.unwrap_or_default())
    }

    /// Create an error toast
    pub fn error(title: String, description: Option<String>) -> Self {
        Self::new(title)
            .with_variant(ToastVariant::Error)
            .with_description(description.unwrap_or_else(|| "An error occurred".to_string()))
    }

    /// Create a warning toast
    pub fn warning(title: String, description: Option<String>) -> Self {
        Self::new(title)
            .with_variant(ToastVariant::Warning)
            .with_description(description.unwrap_or_default())
    }

    /// Create an info toast
    pub fn info(title: String, description: Option<String>) -> Self {
        Self::new(title)
            .with_variant(ToastVariant::Info)
            .with_description(description.unwrap_or_default())
    }

    /// Create a loading toast
    pub fn loading(title: String, description: Option<String>) -> Self {
        Self::new(title)
            .with_variant(ToastVariant::Loading)
            .with_description(description.unwrap_or_default())
            .with_closeable(false)
    }

    /// Get a formatted debug string for error toasts
    pub fn debug_string(&self) -> String {
        if self.variant != ToastVariant::Error {
            return format!("{}: {}", self.title, self.description.as_ref().unwrap_or(&String::new()));
        }

        let mut output = String::new();
        output.push_str(&format!("Error Toast: {}\n", self.title));
        if let Some(desc) = &self.description {
            output.push_str(&format!("Description: {}\n", desc));
        }
        if let Some(metadata) = &self.error_metadata {
            if let Some(code) = &metadata.error_code {
                output.push_str(&format!("Error Code: {}\n", code));
            }
            if let Some(severity) = &metadata.severity {
                output.push_str(&format!("Severity: {}\n", severity));
            }
            if let Some(source) = &metadata.source {
                output.push_str(&format!("Source: {}\n", source));
            }
            if let Some(status) = metadata.status_code {
                output.push_str(&format!("Status Code: {}\n", status));
            }
            if let Some(endpoint) = &metadata.endpoint {
                output.push_str(&format!("Endpoint: {}\n", endpoint));
            }
            if let Some(request_id) = &metadata.request_id {
                output.push_str(&format!("Request ID: {}\n", request_id));
            }
            if !metadata.context.is_empty() {
                output.push_str("Context:\n");
                for (key, value) in &metadata.context {
                    output.push_str(&format!("  {}: {}\n", key, value));
                }
            }
        }
        if !self.recovery_hints.is_empty() {
            output.push_str("Recovery Options:\n");
            for (i, hint) in self.recovery_hints.iter().enumerate() {
                output.push_str(&format!("  {}. {}\n", i + 1, hint.action));
                if let Some(explanation) = &hint.explanation {
                    output.push_str(&format!("     {}\n", explanation));
                }
            }
        }
        output
    }
}
