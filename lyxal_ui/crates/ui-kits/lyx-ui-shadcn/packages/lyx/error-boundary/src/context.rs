//! Rich error context for enhanced debugging and user experience
//!
//! This module provides a comprehensive error context system that includes:
//! - Source location tracking (file, line, module)
//! - Error severity levels
//! - Error chaining and cause preservation
//! - User-friendly messages with recovery suggestions
//! - Technical details for debugging

use std::collections::HashMap;
use std::panic::PanicHookInfo;

/// Severity level of an error
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum ErrorSeverity {
    /// Informational message, not an error
    Info,
    /// Warning that something might be wrong
    Warning,
    /// Error that prevents normal operation
    Error,
    /// Critical error that requires immediate attention
    Critical,
}

impl Default for ErrorSeverity {
    fn default() -> Self {
        Self::Error
    }
}

impl std::fmt::Display for ErrorSeverity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Info => write!(f, "INFO"),
            Self::Warning => write!(f, "WARNING"),
            Self::Error => write!(f, "ERROR"),
            Self::Critical => write!(f, "CRITICAL"),
        }
    }
}

/// Source location where the error occurred
#[derive(Clone, Debug, Default)]
pub struct ErrorSource {
    /// File path where the error occurred
    pub file: Option<String>,
    /// Line number where the error occurred
    pub line: Option<u32>,
    /// Module path where the error occurred
    pub module: Option<String>,
    /// Function name where the error occurred
    pub function: Option<String>,
}

impl ErrorSource {
    /// Create a new error source from the current location
    #[track_caller]
    pub fn here() -> Self {
        let location = std::panic::Location::caller();
        Self {
            file: Some(location.file().to_string()),
            line: Some(location.line()),
            module: None,
            function: None,
        }
    }

    /// Create a new error source with explicit details
    pub fn new(
        file: Option<String>,
        line: Option<u32>,
        module: Option<String>,
        function: Option<String>,
    ) -> Self {
        Self { file, line, module, function }
    }

    /// Set the module path
    pub fn with_module(mut self, module: String) -> Self {
        self.module = Some(module);
        self
    }

    /// Set the function name
    pub fn with_function(mut self, function: String) -> Self {
        self.function = Some(function);
        self
    }
}

impl std::fmt::Display for ErrorSource {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if let Some(file) = &self.file {
            write!(f, "{}", file)?;
            if let Some(line) = self.line {
                write!(f, ":{}", line)?;
            }
            if let Some(function) = &self.function {
                write!(f, " (in {})", function)?;
            } else if let Some(module) = &self.module {
                write!(f, " (in {})", module)?;
            }
        }
        Ok(())
    }
}

/// Recovery suggestion for an error
#[derive(Clone, Debug)]
pub struct RecoverySuggestion {
    /// User-friendly action to take
    pub action: String,
    /// Detailed explanation of why this might help
    pub explanation: Option<String>,
    /// Whether this suggestion is automatic (can be applied by the system)
    pub is_automatic: bool,
}

impl RecoverySuggestion {
    /// Create a new recovery suggestion
    pub fn new(action: String) -> Self {
        Self {
            action,
            explanation: None,
            is_automatic: false,
        }
    }

    /// Add an explanation to the suggestion
    pub fn with_explanation(mut self, explanation: String) -> Self {
        self.explanation = Some(explanation);
        self
    }

    /// Mark this as an automatic recovery suggestion
    pub fn automatic(mut self) -> Self {
        self.is_automatic = true;
        self
    }
}

/// Rich error context with debugging information
#[derive(Clone, Debug)]
pub struct ErrorContext {
    /// User-friendly error message
    pub message: String,
    /// Technical error details for debugging
    pub technical_details: Option<String>,
    /// Severity level of the error
    pub severity: ErrorSeverity,
    /// Source location where the error occurred
    pub source: ErrorSource,
    /// Recovery suggestions
    pub recovery_suggestions: Vec<RecoverySuggestion>,
    /// Additional context metadata
    pub metadata: HashMap<String, String>,
    /// Underlying error cause (for error chaining)
    pub cause: Option<String>,
    /// Error code for categorization
    pub error_code: Option<String>,
    /// Timestamp when the error occurred
    pub timestamp: Option<chrono::DateTime<chrono::Utc>>,
}

impl ErrorContext {
    /// Create a new error context with a message
    #[track_caller]
    pub fn new(message: String) -> Self {
        Self {
            message,
            technical_details: None,
            severity: ErrorSeverity::default(),
            source: ErrorSource::here(),
            recovery_suggestions: Vec::new(),
            metadata: HashMap::new(),
            cause: None,
            error_code: None,
            timestamp: Some(chrono::Utc::now()),
        }
    }

    /// Create a new error context from a panic
    pub fn from_panic(panic_info: &PanicHookInfo<'_>) -> Self {
        let payload = panic_info.payload();
        let message = if let Some(s) = payload.downcast_ref::<&str>() {
            s.to_string()
        } else if let Some(s) = payload.downcast_ref::<String>() {
            s.clone()
        } else {
            "Unknown panic occurred".to_string()
        };

        let location = panic_info.location().map(|loc| ErrorSource {
            file: Some(loc.file().to_string()),
            line: Some(loc.line()),
            module: None,
            function: None,
        });

        Self {
            message: "An unexpected error occurred. Please try refreshing the page.".to_string(),
            technical_details: Some(format!("Panic: {}", message)),
            severity: ErrorSeverity::Critical,
            source: location.unwrap_or_default(),
            recovery_suggestions: vec![
                RecoverySuggestion::new("Refresh the page".to_string())
                    .with_explanation("This will reload the application and clear any temporary errors.".to_string())
                    .automatic(),
            ],
            metadata: HashMap::new(),
            cause: Some(message),
            error_code: Some("PANIC".to_string()),
            timestamp: Some(chrono::Utc::now()),
        }
    }

    /// Set the technical details
    pub fn with_technical_details(mut self, details: String) -> Self {
        self.technical_details = Some(details);
        self
    }

    /// Set the severity level
    pub fn with_severity(mut self, severity: ErrorSeverity) -> Self {
        self.severity = severity;
        self
    }

    /// Set the source location
    pub fn with_source(mut self, source: ErrorSource) -> Self {
        self.source = source;
        self
    }

    /// Add a recovery suggestion
    pub fn with_suggestion(mut self, suggestion: RecoverySuggestion) -> Self {
        self.recovery_suggestions.push(suggestion);
        self
    }

    /// Add metadata
    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }

    /// Set the underlying cause
    pub fn with_cause(mut self, cause: String) -> Self {
        self.cause = Some(cause);
        self
    }

    /// Set the error code
    pub fn with_error_code(mut self, code: String) -> Self {
        self.error_code = Some(code);
        self
    }

    /// Add multiple metadata key-value pairs
    pub fn with_metadata_map(mut self, metadata: HashMap<String, String>) -> Self {
        self.metadata.extend(metadata);
        self
    }

    /// Get a formatted display string
    pub fn display(&self) -> String {
        let mut output = String::new();
        output.push_str(&self.message);
        if let Some(error_code) = &self.error_code {
            output.push_str(&format!(" [{}]", error_code));
        }
        output
    }

    /// Get a detailed debugging string
    pub fn debug_string(&self) -> String {
        let mut output = String::new();
        output.push_str(&format!("Severity: {}\n", self.severity));
        output.push_str(&format!("Message: {}\n", self.message));
        if let Some(error_code) = &self.error_code {
            output.push_str(&format!("Error Code: {}\n", error_code));
        }
        if let Some(technical) = &self.technical_details {
            output.push_str(&format!("Technical Details: {}\n", technical));
        }
        if let Some(cause) = &self.cause {
            output.push_str(&format!("Cause: {}\n", cause));
        }
        if self.source.file.is_some() {
            output.push_str(&format!("Source: {}\n", self.source));
        }
        if !self.recovery_suggestions.is_empty() {
            output.push_str("Recovery Suggestions:\n");
            for (i, suggestion) in self.recovery_suggestions.iter().enumerate() {
                output.push_str(&format!("  {}. {}\n", i + 1, suggestion.action));
                if let Some(explanation) = &suggestion.explanation {
                    output.push_str(&format!("     {}\n", explanation));
                }
            }
        }
        if !self.metadata.is_empty() {
            output.push_str("Metadata:\n");
            for (key, value) in &self.metadata {
                output.push_str(&format!("  {}: {}\n", key, value));
            }
        }
        output
    }

    /// Convert to legacy ErrorInfo for backwards compatibility
    pub fn to_error_info(&self) -> super::ErrorInfo {
        super::ErrorInfo {
            message: self.display(),
            technical_details: Some(self.debug_string()),
        }
    }
}

impl std::fmt::Display for ErrorContext {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.display())
    }
}

impl std::error::Error for ErrorContext {}

impl std::fmt::Display for super::ErrorInfo {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl std::error::Error for super::ErrorInfo {}

/// Builder for creating error contexts with a fluent API
pub struct ErrorContextBuilder {
    context: ErrorContext,
}

impl ErrorContextBuilder {
    /// Create a new builder with a message
    #[track_caller]
    pub fn new(message: String) -> Self {
        Self {
            context: ErrorContext::new(message),
        }
    }

    /// Set technical details
    pub fn technical_details(mut self, details: String) -> Self {
        self.context.technical_details = Some(details);
        self
    }

    /// Set severity level
    pub fn severity(mut self, severity: ErrorSeverity) -> Self {
        self.context.severity = severity;
        self
    }

    /// Set source location
    pub fn source(mut self, source: ErrorSource) -> Self {
        self.context.source = source;
        self
    }

    /// Add a recovery suggestion
    pub fn suggestion(mut self, action: String) -> Self {
        self.context.recovery_suggestions.push(RecoverySuggestion::new(action));
        self
    }

    /// Add a recovery suggestion with explanation
    pub fn suggestion_with_explanation(mut self, action: String, explanation: String) -> Self {
        self.context.recovery_suggestions.push(
            RecoverySuggestion::new(action).with_explanation(explanation)
        );
        self
    }

    /// Add metadata
    pub fn metadata(mut self, key: String, value: String) -> Self {
        self.context.metadata.insert(key, value);
        self
    }

    /// Set underlying cause
    pub fn cause(mut self, cause: String) -> Self {
        self.context.cause = Some(cause);
        self
    }

    /// Set error code
    pub fn error_code(mut self, code: String) -> Self {
        self.context.error_code = Some(code);
        self
    }

    /// Build the error context
    pub fn build(self) -> ErrorContext {
        self.context
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_context_creation() {
        let context = ErrorContext::new("Test error".to_string());
        assert_eq!(context.message, "Test error");
        assert_eq!(context.severity, ErrorSeverity::Error);
        assert!(context.source.file.is_some());
    }

    #[test]
    fn test_error_context_builder() {
        let context = ErrorContextBuilder::new("Builder test".to_string())
            .severity(ErrorSeverity::Warning)
            .technical_details("Technical info".to_string())
            .error_code("TEST_001".to_string())
            .metadata("key".to_string(), "value".to_string())
            .build();

        assert_eq!(context.message, "Builder test");
        assert_eq!(context.severity, ErrorSeverity::Warning);
        assert_eq!(context.technical_details, Some("Technical info".to_string()));
        assert_eq!(context.error_code, Some("TEST_001".to_string()));
        assert_eq!(context.metadata.get("key"), Some(&"value".to_string()));
    }

    #[test]
    fn test_recovery_suggestion() {
        let suggestion = RecoverySuggestion::new("Try again".to_string())
            .with_explanation("This might help".to_string())
            .automatic();

        assert_eq!(suggestion.action, "Try again");
        assert_eq!(suggestion.explanation, Some("This might help".to_string()));
        assert!(suggestion.is_automatic);
    }

    #[test]
    fn test_error_source_display() {
        let source = ErrorSource::new(
            Some("file.rs".to_string()),
            Some(42),
            Some("module".to_string()),
            Some("function".to_string()),
        );

        let display = format!("{}", source);
        assert!(display.contains("file.rs:42"));
        assert!(display.contains("function"));
    }

    #[test]
    fn test_error_context_from_panic() {
        let message = "Panic message";
        let panic_info = create_test_panic_info(message);
        let context = ErrorContext::from_panic(&panic_info);

        assert_eq!(context.severity, ErrorSeverity::Critical);
        assert_eq!(context.technical_details, Some(format!("Panic: {}", message)));
        assert_eq!(context.cause, Some(message.to_string()));
        assert_eq!(context.error_code, Some("PANIC".to_string()));
        assert!(!context.recovery_suggestions.is_empty());
    }

    #[test]
    fn test_error_severity_ordering() {
        assert!(ErrorSeverity::Info < ErrorSeverity::Warning);
        assert!(ErrorSeverity::Warning < ErrorSeverity::Error);
        assert!(ErrorSeverity::Error < ErrorSeverity::Critical);
    }

    // Helper function for testing panic info
    fn create_test_panic_info(message: &str) -> PanicHookInfo<'static> {
        // Create a boxed panic payload
        let payload: Box<dyn std::any::Any + Send> = Box::new(message.to_string());

        // Use unsafe to create PanicHookInfo (this is only for testing)
        unsafe {
            std::panic::PanicHookInfo::new(
                payload,
                Some(std::panic::Location::caller()),
                false,
            )
        }
    }

    #[test]
    fn test_error_context_display() {
        let context = ErrorContextBuilder::new("Display test".to_string())
            .error_code("ERR_001".to_string())
            .build();

        let display = context.display();
        assert!(display.contains("Display test"));
        assert!(display.contains("[ERR_001]"));
    }

    #[test]
    fn test_error_context_debug_string() {
        let context = ErrorContextBuilder::new("Debug test".to_string())
            .severity(ErrorSeverity::Critical)
            .technical_details("Technical details".to_string())
            .suggestion_with_explanation("Retry".to_string(), "Try again".to_string())
            .metadata("key1".to_string(), "value1".to_string())
            .build();

        let debug_str = context.debug_string();
        assert!(debug_str.contains("CRITICAL"));
        assert!(debug_str.contains("Debug test"));
        assert!(debug_str.contains("Technical details"));
        assert!(debug_str.contains("Retry"));
        assert!(debug_str.contains("Try again"));
        assert!(debug_str.contains("key1"));
        assert!(debug_str.contains("value1"));
    }

    #[test]
    fn test_error_context_to_error_info() {
        let context = ErrorContextBuilder::new("Conversion test".to_string())
            .technical_details("Technical".to_string())
            .build();

        let error_info = context.to_error_info();
        assert_eq!(error_info.message, "Conversion test");
        assert!(error_info.technical_details.is_some());
        assert!(error_info.technical_details.unwrap().contains("Technical"));
    }

    #[test]
    fn test_error_source_here() {
        let source = ErrorSource::here();
        assert!(source.file.is_some());
        assert!(source.line.is_some());
    }
}
