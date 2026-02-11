//! Core validation types for the Input component
//!
//! This module defines the fundamental types used throughout the validation system,
//! including enhanced error context with user guidance and field-specific debugging information.

use std::collections::HashMap;

/// Validation rule types for different input validation scenarios
#[derive(Clone, Debug, PartialEq)]
pub enum ValidationRule {
    Required,
    MinLength(usize),
    MaxLength(usize),
    Email,
    Pattern(String),
    Custom(String), // Store a description instead of the function for Clone/Debug/PartialEq
}

impl ValidationRule {
    /// Get a user-friendly description of the rule
    pub fn description(&self) -> String {
        match self {
            Self::Required => "This field is required".to_string(),
            Self::MinLength(n) => format!("Must be at least {} characters long", n),
            Self::MaxLength(n) => format!("Must be no more than {} characters long", n),
            Self::Email => "Must be a valid email address".to_string(),
            Self::Pattern(_) => "Must match the required pattern".to_string(),
            Self::Custom(desc) => desc.clone(),
        }
    }

    /// Get a user-friendly suggestion for fixing the validation error
    pub fn suggestion(&self) -> Option<String> {
        match self {
            Self::Required => Some("Please enter a value for this field".to_string()),
            Self::MinLength(n) => Some(format!("Enter at least {} characters", n)),
            Self::MaxLength(n) => Some(format!("Reduce to {} or fewer characters", n)),
            Self::Email => Some("Enter a valid email address (e.g., user@example.com)".to_string()),
            Self::Pattern(_) => Some("Ensure your input matches the required format".to_string()),
            Self::Custom(_) => None,
        }
    }
}

/// Severity level for validation errors
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum ValidationSeverity {
    /// Informational notice
    Info,
    /// Warning that doesn't prevent submission
    Warning,
    /// Error that must be fixed
    Error,
    /// Critical error that blocks the entire form
    Critical,
}

impl Default for ValidationSeverity {
    fn default() -> Self {
        Self::Error
    }
}

/// Source location for the validation error
#[derive(Clone, Debug, Default)]
pub struct ValidationErrorSource {
    /// Field name where the error occurred
    pub field: String,
    /// Form name (if applicable)
    pub form_name: Option<String>,
    /// Component name
    pub component: Option<String>,
    /// Validation step that failed
    pub validation_step: Option<String>,
}

impl ValidationErrorSource {
    /// Create a new validation error source
    pub fn new(field: String) -> Self {
        Self {
            field,
            form_name: None,
            component: None,
            validation_step: None,
        }
    }

    /// Set the form name
    pub fn with_form(mut self, form: String) -> Self {
        self.form_name = Some(form);
        self
    }

    /// Set the component name
    pub fn with_component(mut self, component: String) -> Self {
        self.component = Some(component);
        self
    }

    /// Set the validation step
    pub fn with_step(mut self, step: String) -> Self {
        self.validation_step = Some(step);
        self
    }
}

/// Recovery suggestion for validation errors
#[derive(Clone, Debug, PartialEq)]
pub struct ValidationRecoverySuggestion {
    /// User-friendly action to take
    pub action: String,
    /// Detailed explanation
    pub explanation: Option<String>,
    /// Example value (if applicable)
    pub example: Option<String>,
}

impl ValidationRecoverySuggestion {
    /// Create a new recovery suggestion
    pub fn new(action: String) -> Self {
        Self {
            action,
            explanation: None,
            example: None,
        }
    }

    /// Add an explanation
    pub fn with_explanation(mut self, explanation: String) -> Self {
        self.explanation = Some(explanation);
        self
    }

    /// Add an example
    pub fn with_example(mut self, example: String) -> Self {
        self.example = Some(example);
        self
    }
}

/// Enhanced validation error with field context and user guidance
#[derive(Clone, Debug, PartialEq)]
pub struct ValidationError {
    /// Field name where the error occurred
    pub field: String,
    /// Error message
    pub message: String,
    /// The rule that failed
    pub rule: ValidationRule,
    /// Severity level
    pub severity: ValidationSeverity,
    /// User-friendly suggestions for fixing the error
    pub suggestions: Vec<ValidationRecoverySuggestion>,
    /// Current invalid value (if available)
    pub current_value: Option<String>,
    /// Expected format or value
    pub expected_format: Option<String>,
    /// Additional context metadata
    pub metadata: HashMap<String, String>,
}

impl ValidationError {
    /// Create a new validation error
    pub fn new(field: String, message: String, rule: ValidationRule) -> Self {
        let suggestions = if let Some(suggestion) = rule.suggestion() {
            vec![ValidationRecoverySuggestion::new(suggestion)]
        } else {
            Vec::new()
        };

        Self {
            field,
            message,
            rule,
            severity: ValidationSeverity::default(),
            suggestions,
            current_value: None,
            expected_format: None,
            metadata: HashMap::new(),
        }
    }

    /// Set the severity level
    pub fn with_severity(mut self, severity: ValidationSeverity) -> Self {
        self.severity = severity;
        self
    }

    /// Add a suggestion
    pub fn with_suggestion(mut self, suggestion: ValidationRecoverySuggestion) -> Self {
        self.suggestions.push(suggestion);
        self
    }

    /// Set the current value that failed validation
    pub fn with_current_value(mut self, value: String) -> Self {
        self.current_value = Some(value);
        self
    }

    /// Set the expected format
    pub fn with_expected_format(mut self, format: String) -> Self {
        self.expected_format = Some(format);
        self
    }

    /// Add metadata
    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }

    /// Get a user-friendly display message
    pub fn display_message(&self) -> String {
        let mut msg = format!("{}: {}", self.field, self.message);
        if let Some(format) = &self.expected_format {
            msg.push_str(&format!(" (Expected: {})", format));
        }
        msg
    }

    /// Get detailed debugging information
    pub fn debug_details(&self) -> String {
        let mut output = String::new();
        output.push_str(&format!("Field: {}\n", self.field));
        output.push_str(&format!("Severity: {:?}\n", self.severity));
        output.push_str(&format!("Message: {}\n", self.message));
        output.push_str(&format!("Rule: {:?}\n", self.rule));
        if let Some(value) = &self.current_value {
            output.push_str(&format!("Current Value: {}\n", value));
        }
        if let Some(format) = &self.expected_format {
            output.push_str(&format!("Expected Format: {}\n", format));
        }
        if !self.suggestions.is_empty() {
            output.push_str("Suggestions:\n");
            for (i, suggestion) in self.suggestions.iter().enumerate() {
                output.push_str(&format!("  {}. {}\n", i + 1, suggestion.action));
                if let Some(explanation) = &suggestion.explanation {
                    output.push_str(&format!("     {}\n", explanation));
                }
                if let Some(example) = &suggestion.example {
                    output.push_str(&format!("     Example: {}\n", example));
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
}

/// Validation result containing errors and overall validity
#[derive(Clone, Debug, PartialEq)]
pub struct ValidationResult {
    pub is_valid: bool,
    pub errors: Vec<ValidationError>,
}

impl ValidationResult {
    pub fn new() -> Self {
        Self {
            is_valid: true,
            errors: Vec::new(),
        }
    }

    pub fn add_error(&mut self, field: impl Into<String>, message: impl Into<String>, rule: ValidationRule) {
        self.is_valid = false;
        self.errors.push(ValidationError::new(field.into(), message.into(), rule));
    }

    /// Add a validation error with enhanced context
    pub fn add_error_with_context(&mut self, error: ValidationError) {
        self.is_valid = false;
        self.errors.push(error);
    }

    pub fn get_field_error(&self, field: &str) -> Option<&ValidationError> {
        self.errors.iter().find(|error| error.field == field)
    }

    pub fn has_field_error(&self, field: &str) -> bool {
        self.errors.iter().any(|error| error.field == field)
    }

    pub fn is_field_valid(&self, field: &str) -> bool {
        !self.has_field_error(field)
    }

    pub fn has_errors(&self) -> bool {
        !self.is_valid
    }

    pub fn get_error_message(&self, field: &str) -> Option<&str> {
        self.get_field_error(field).map(|error| error.message.as_str())
    }

    /// Get errors by severity level
    pub fn errors_by_severity(&self, severity: ValidationSeverity) -> Vec<&ValidationError> {
        self.errors.iter()
            .filter(|error| error.severity == severity)
            .collect()
    }

    /// Get critical errors that block form submission
    pub fn critical_errors(&self) -> Vec<&ValidationError> {
        self.errors_by_severity(ValidationSeverity::Critical)
    }

    /// Get all error messages for display
    pub fn all_error_messages(&self) -> Vec<String> {
        self.errors.iter()
            .map(|error| error.display_message())
            .collect()
    }

    /// Get a detailed debugging summary
    pub fn debug_summary(&self) -> String {
        let mut output = String::new();
        output.push_str(&format!("Valid: {}\n", self.is_valid));
        output.push_str(&format!("Error Count: {}\n", self.errors.len()));
        if !self.errors.is_empty() {
            output.push_str("\nErrors:\n");
            for (i, error) in self.errors.iter().enumerate() {
                output.push_str(&format!("{}. {}\n", i + 1, error.display_message()));
            }
        }
        output
    }
}

/// Validation context for managing multiple field validations
#[derive(Clone, Debug)]
pub struct ValidationContext {
    pub results: HashMap<String, ValidationResult>,
    /// Form name for context
    pub form_name: Option<String>,
    /// Additional context metadata
    pub metadata: HashMap<String, String>,
}

impl ValidationContext {
    pub fn new() -> Self {
        Self {
            results: HashMap::new(),
            form_name: None,
            metadata: HashMap::new(),
        }
    }

    /// Set the form name
    pub fn with_form(mut self, form: String) -> Self {
        self.form_name = Some(form);
        self
    }

    pub fn add_field_result(&mut self, field: String, result: ValidationResult) {
        self.results.insert(field, result);
    }

    pub fn get_field_result(&self, field: &str) -> Option<&ValidationResult> {
        self.results.get(field)
    }

    pub fn get_field_error(&self, field: &str) -> Option<&ValidationError> {
        self.results.get(field)
            .and_then(|result| result.get_field_error(field))
    }

    pub fn has_field_error(&self, field: &str) -> bool {
        self.results.get(field)
            .map(|result| result.has_field_error(field))
            .unwrap_or(false)
    }

    pub fn is_field_valid(&self, field: &str) -> bool {
        self.results.get(field)
            .map(|result| result.is_valid)
            .unwrap_or(true)
    }

    pub fn is_all_valid(&self) -> bool {
        self.results.values().all(|result| result.is_valid)
    }

    pub fn get_all_errors(&self) -> Vec<&ValidationError> {
        self.results.values()
            .flat_map(|result| &result.errors)
            .collect()
    }

    /// Get all critical errors across all fields
    pub fn get_critical_errors(&self) -> Vec<&ValidationError> {
        self.get_all_errors().into_iter()
            .filter(|error| error.severity == ValidationSeverity::Critical)
            .collect()
    }

    /// Get a summary of validation state
    pub fn summary(&self) -> ValidationSummary {
        let all_errors = self.get_all_errors();
        let field_count = self.results.len();
        let valid_field_count = self.results.values().filter(|r| r.is_valid).count();
        let critical_errors = all_errors.iter()
            .filter(|e| e.severity == ValidationSeverity::Critical)
            .count();
        let warning_errors = all_errors.iter()
            .filter(|e| e.severity == ValidationSeverity::Warning)
            .count();

        ValidationSummary {
            is_valid: self.is_all_valid(),
            field_count,
            valid_field_count,
            total_errors: all_errors.len(),
            critical_errors,
            warning_errors,
        }
    }

    /// Add context metadata
    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }
}

impl Default for ValidationContext {
    fn default() -> Self {
        Self::new()
    }
}

impl Default for ValidationResult {
    fn default() -> Self {
        Self::new()
    }
}

/// Summary of validation state for quick status checks
#[derive(Clone, Debug, PartialEq)]
pub struct ValidationSummary {
    /// Overall validity status
    pub is_valid: bool,
    /// Total number of fields validated
    pub field_count: usize,
    /// Number of valid fields
    pub valid_field_count: usize,
    /// Total number of errors
    pub total_errors: usize,
    /// Number of critical errors
    pub critical_errors: usize,
    /// Number of warning-level errors
    pub warning_errors: usize,
}

impl ValidationSummary {
    /// Get a user-friendly status message
    pub fn status_message(&self) -> String {
        if self.is_valid {
            format!("All {} fields are valid", self.field_count)
        } else if self.critical_errors > 0 {
            format!("{} critical error(s) must be fixed", self.critical_errors)
        } else {
            format!("{} error(s) need attention", self.total_errors)
        }
    }

    /// Get a detailed summary for debugging
    pub fn debug_details(&self) -> String {
        format!(
            "Validation Summary:\n  Valid: {}\n  Fields: {}/{}\n  Errors: {} ({} critical, {} warnings)",
            self.is_valid,
            self.valid_field_count,
            self.field_count,
            self.total_errors,
            self.critical_errors,
            self.warning_errors
        )
    }
}
