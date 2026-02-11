### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\errors.rs
```rust
//! Error types for CLI operations with enhanced debugging context
//!
//! This module provides comprehensive error types for CLI operations,
//! including user-friendly messages, technical details, and recovery suggestions.

use std::collections::HashMap;

/// Error severity level for CLI errors
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum CliErrorSeverity {
    /// Informational message
    Info,
    /// Warning that doesn't prevent operation
    Warning,
    /// Error that prevents operation
    Error,
    /// Critical error that requires immediate attention
    Critical,
}

impl Default for CliErrorSeverity {
    fn default() -> Self {
        Self::Error
    }
}

/// Recovery suggestion for CLI errors
#[derive(Clone, Debug)]
pub struct CliRecoverySuggestion {
    /// User-friendly action to take
    pub action: String,
    /// Detailed explanation
    pub explanation: Option<String>,
    /// Example command to run
    pub example_command: Option<String>,
}

impl CliRecoverySuggestion {
    pub fn new(action: String) -> Self {
        Self {
            action,
            explanation: None,
            example_command: None,
        }
    }

    pub fn with_explanation(mut self, explanation: String) -> Self {
        self.explanation = Some(explanation);
        self
    }

    pub fn with_example(mut self, example: String) -> Self {
        self.example_command = Some(example);
        self
    }
}

/// Enhanced error context for CLI operations
#[derive(Clone, Debug)]
pub struct CliErrorContext {
    /// Error type identifier
    pub error_type: ErrorType,
    /// User-friendly error message
    pub message: String,
    /// Technical details for debugging
    pub technical_details: Option<String>,
    /// Severity level
    pub severity: CliErrorSeverity,
    /// Recovery suggestions
    pub recovery_suggestions: Vec<CliRecoverySuggestion>,
    /// Additional context metadata
    pub metadata: HashMap<String, String>,
    /// Related file paths
    pub related_paths: Vec<String>,
    /// Command that caused the error (if applicable)
    pub command: Option<String>,
}

impl CliErrorContext {
    pub fn new(error_type: ErrorType, message: String) -> Self {
        Self {
            error_type,
            message,
            technical_details: None,
            severity: CliErrorSeverity::default(),
            recovery_suggestions: Vec::new(),
            metadata: HashMap::new(),
            related_paths: Vec::new(),
            command: None,
        }
    }

    pub fn with_technical_details(mut self, details: String) -> Self {
        self.technical_details = Some(details);
        self
    }

    pub fn with_severity(mut self, severity: CliErrorSeverity) -> Self {
        self.severity = severity;
        self
    }

    pub fn with_suggestion(mut self, suggestion: CliRecoverySuggestion) -> Self {
        self.recovery_suggestions.push(suggestion);
        self
    }

    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }

    pub fn with_related_path(mut self, path: String) -> Self {
        self.related_paths.push(path);
        self
    }

    pub fn with_command(mut self, command: String) -> Self {
        self.command = Some(command);
        self
    }

    /// Get user-friendly display message
    pub fn display(&self) -> String {
        let mut output = format!("Error: {}", self.message);
        if let Some(code) = self.error_type.error_code() {
            output.push_str(&format!(" [{}]", code));
        }
        output
    }

    /// Get detailed debugging information
    pub fn debug_details(&self) -> String {
        let mut output = String::new();
        output.push_str(&format!("Error Type: {:?}\n", self.error_type));
        output.push_str(&format!("Severity: {:?}\n", self.severity));
        output.push_str(&format!("Message: {}\n", self.message));
        if let Some(code) = self.error_type.error_code() {
            output.push_str(&format!("Error Code: {}\n", code));
        }
        if let Some(technical) = &self.technical_details {
            output.push_str(&format!("Technical Details: {}\n", technical));
        }
        if let Some(command) = &self.command {
            output.push_str(&format!("Command: {}\n", command));
        }
        if !self.related_paths.is_empty() {
            output.push_str("Related Paths:\n");
            for path in &self.related_paths {
                output.push_str(&format!("  - {}\n", path));
            }
        }
        if !self.recovery_suggestions.is_empty() {
            output.push_str("Recovery Suggestions:\n");
            for (i, suggestion) in self.recovery_suggestions.iter().enumerate() {
                output.push_str(&format!("  {}. {}\n", i + 1, suggestion.action));
                if let Some(explanation) = &suggestion.explanation {
                    output.push_str(&format!("     {}\n", explanation));
                }
                if let Some(example) = &suggestion.example_command {
                    output.push_str(&format!("     Example: {}\n", example));
                }
            }
        }
        if !self.metadata.is_empty() {
            output.push_str("Context:\n");
            for (key, value) in &self.metadata {
                output.push_str(&format!("  {}: {}\n", key, value));
            }
        }
        output
    }
}

impl std::fmt::Display for CliErrorContext {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.display())
    }
}

impl std::error::Error for CliErrorContext {}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub enum ErrorType {
    MissingDirOrEmptyProject,
    ExistingConfig,
    MissingConfig,
    FailedConfigRead,
    TailwindNotConfigured,
    ImportAliasMissing,
    UnsupportedFramework,
    ComponentUrlNotFound,
    ComponentUrlUnauthorized,
    ComponentUrlForbidden,
    ComponentUrlBadRequest,
    ComponentUrlInternalServerError,
}

impl ErrorType {
    /// Get error code for categorization
    pub fn error_code(&self) -> Option<&'static str> {
        match self {
            Self::MissingDirOrEmptyProject => Some("CLI_001"),
            Self::ExistingConfig => Some("CLI_002"),
            Self::MissingConfig => Some("CLI_003"),
            Self::FailedConfigRead => Some("CLI_004"),
            Self::TailwindNotConfigured => Some("CLI_005"),
            Self::ImportAliasMissing => Some("CLI_006"),
            Self::UnsupportedFramework => Some("CLI_007"),
            Self::ComponentUrlNotFound => Some("HTTP_404"),
            Self::ComponentUrlUnauthorized => Some("HTTP_401"),
            Self::ComponentUrlForbidden => Some("HTTP_403"),
            Self::ComponentUrlBadRequest => Some("HTTP_400"),
            Self::ComponentUrlInternalServerError => Some("HTTP_500"),
        }
    }

    /// Get user-friendly description
    pub fn description(&self) -> &'static str {
        match self {
            Self::MissingDirOrEmptyProject => "Project directory is missing or empty",
            Self::ExistingConfig => "Configuration already exists",
            Self::MissingConfig => "Configuration file not found",
            Self::FailedConfigRead => "Failed to read configuration",
            Self::TailwindNotConfigured => "Tailwind CSS is not configured",
            Self::ImportAliasMissing => "Import alias is missing",
            Self::UnsupportedFramework => "Framework is not supported",
            Self::ComponentUrlNotFound => "Component not found",
            Self::ComponentUrlUnauthorized => "Authentication required",
            Self::ComponentUrlForbidden => "Access forbidden",
            Self::ComponentUrlBadRequest => "Invalid request",
            Self::ComponentUrlInternalServerError => "Server error occurred",
        }
    }

    /// Get default recovery suggestions
    pub fn default_suggestions(&self) -> Vec<CliRecoverySuggestion> {
        match self {
            Self::MissingDirOrEmptyProject => vec![
                CliRecoverySuggestion::new("Initialize a new project".to_string())
                    .with_example("rust-shadcn init ."),
                CliRecoverySuggestion::new("Check you're in the correct directory".to_string()),
            ],
            Self::ExistingConfig => vec![
                CliRecoverySuggestion::new("Remove existing config first".to_string())
                    .with_example("rm components.json"),
                CliRecoverySuggestion::new("Use --force to overwrite".to_string())
                    .with_example("rust-shadcn init --force"),
            ],
            Self::MissingConfig => vec![
                CliRecoverySuggestion::new("Initialize the project first".to_string())
                    .with_example("rust-shadcn init"),
            ],
            Self::FailedConfigRead => vec![
                CliRecoverySuggestion::new("Check file permissions".to_string()),
                CliRecoverySuggestion::new("Verify config file format".to_string())
                    .with_example("cat components.json"),
            ],
            Self::TailwindNotConfigured => vec![
                CliRecoverySuggestion::new("Install and configure Tailwind CSS".to_string())
                    .with_example("npm install -D tailwindcss"),
                CliRecoverySuggestion::new("Create tailwind.config.js".to_string())
                    .with_example("npx tailwindcss init"),
            ],
            Self::ImportAliasMissing => vec![
                CliRecoverySuggestion::new("Add import alias to tsconfig.json".to_string())
                    .with_example(r#""paths": { "@/*": ["./*"] }"#),
            ],
            Self::UnsupportedFramework => vec![
                CliRecoverySuggestion::new("Use a supported framework (leptos)".to_string()),
            ],
            Self::ComponentUrlNotFound => vec![
                CliRecoverySuggestion::new("Check component name spelling".to_string())
                    .with_example("rust-shadcn list"),
                CliRecoverySuggestion::new("Verify internet connection".to_string()),
            ],
            Self::ComponentUrlUnauthorized => vec![
                CliRecoverySuggestion::new("Check authentication credentials".to_string()),
            ],
            Self::ComponentUrlForbidden => vec![
                CliRecoverySuggestion::new("Verify you have access to this component".to_string()),
            ],
            Self::ComponentUrlBadRequest => vec![
                CliRecoverySuggestion::new("Check your request parameters".to_string()),
            ],
            Self::ComponentUrlInternalServerError => vec![
                CliRecoverySuggestion::new("Try again later".to_string()),
                CliRecoverySuggestion::new("Report the issue if it persists".to_string())
                    .with_example("https://github.com/rust-for-web/shadcn/issues"),
            ],
        }
    }

    /// Create an enhanced error context
    pub fn to_error_context(&self, custom_message: Option<String>) -> CliErrorContext {
        let message = custom_message.unwrap_or_else(|| self.description().to_string());
        let mut context = CliErrorContext::new(*self, message);

        // Set severity based on error type
        let severity = match self {
            Self::ComponentUrlInternalServerError => CliErrorSeverity::Critical,
            Self::MissingDirOrEmptyProject |
            Self::MissingConfig |
            Self::FailedConfigRead |
            Self::TailwindNotConfigured => CliErrorSeverity::Error,
            Self::ExistingConfig |
            Self::ImportAliasMissing |
            Self::UnsupportedFramework => CliErrorSeverity::Warning,
            _ => CliErrorSeverity::Error,
        };
        context = context.with_severity(severity);

        // Add default suggestions
        for suggestion in self.default_suggestions() {
            context = context.with_suggestion(suggestion);
        }

        context
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_type_codes() {
        assert_eq!(ErrorType::MissingConfig.error_code(), Some("CLI_003"));
        assert_eq!(ErrorType::ComponentUrlNotFound.error_code(), Some("HTTP_404"));
    }

    #[test]
    fn test_error_context_creation() {
        let context = ErrorType::MissingConfig.to_error_context(None);
        assert_eq!(context.error_type, ErrorType::MissingConfig);
        assert!(!context.recovery_suggestions.is_empty());
    }

    #[test]
    fn test_recovery_suggestions() {
        let suggestions = ErrorType::ExistingConfig.default_suggestions();
        assert!(!suggestions.is_empty());
        assert!(suggestions.iter().any(|s| s.example_command.is_some()));
    }

    #[test]
    fn test_error_display() {
        let context = ErrorType::MissingConfig.to_error_context(None);
        let display = context.display();
        assert!(display.contains("Configuration file not found"));
        assert!(display.contains("[CLI_003]"));
    }

    #[test]
    fn test_error_debug_details() {
        let context = ErrorType::MissingConfig.to_error_context(None)
            .with_command("rust-shadcn add button".to_string())
            .with_related_path("/project/components.json".to_string());

        let details = context.debug_details();
        assert!(details.contains("Severity:"));
        assert!(details.contains("Command: rust-shadcn add button"));
        assert!(details.contains("/project/components.json"));
        assert!(details.contains("Recovery Suggestions:"));
    }
}
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
