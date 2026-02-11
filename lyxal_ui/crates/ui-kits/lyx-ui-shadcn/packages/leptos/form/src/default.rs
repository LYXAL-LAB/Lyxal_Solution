use leptos::prelude::*;
use leptos_style::Style;
use web_sys::{HtmlFormElement, HtmlInputElement, SubmitEvent};
use wasm_bindgen::JsCast;
use std::collections::HashMap;

/// Severity level for form errors
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum FormErrorSeverity {
    /// Informational notice
    Info,
    /// Warning that doesn't prevent submission
    Warning,
    /// Error that must be fixed before submission
    Error,
    /// Critical error that blocks the entire form
    Critical,
}

impl Default for FormErrorSeverity {
    fn default() -> Self {
        Self::Error
    }
}

/// Source location for form errors
#[derive(Clone, Debug)]
pub struct FormErrorSource {
    /// Field name where the error occurred
    pub field: String,
    /// Form ID or name
    pub form_id: Option<String>,
    /// Component that reported the error
    pub component: Option<String>,
    /// Step in the submission process
    pub submission_step: Option<String>,
}

impl FormErrorSource {
    pub fn new(field: String) -> Self {
        Self {
            field,
            form_id: None,
            component: None,
            submission_step: None,
        }
    }

    pub fn with_form(mut self, form_id: String) -> Self {
        self.form_id = Some(form_id);
        self
    }

    pub fn with_component(mut self, component: String) -> Self {
        self.component = Some(component);
        self
    }

    pub fn with_step(mut self, step: String) -> Self {
        self.submission_step = Some(step);
        self
    }
}

/// Recovery suggestion for form errors
#[derive(Clone, Debug)]
pub struct FormRecoverySuggestion {
    /// User-friendly action to take
    pub action: String,
    /// Detailed explanation
    pub explanation: Option<String>,
    /// Whether the fix can be applied automatically
    pub is_automatic: bool,
}

impl FormRecoverySuggestion {
    pub fn new(action: String) -> Self {
        Self {
            action,
            explanation: None,
            is_automatic: false,
        }
    }

    pub fn with_explanation(mut self, explanation: String) -> Self {
        self.explanation = Some(explanation);
        self
    }

    pub fn automatic(mut self) -> Self {
        self.is_automatic = true;
        self
    }
}

/// Enhanced form validation error with submission context
#[derive(Clone, Debug)]
pub struct FormError {
    pub field: String,
    pub message: String,
    /// Severity level of the error
    pub severity: FormErrorSeverity,
    /// Source location information
    pub source: FormErrorSource,
    /// Recovery suggestions
    pub suggestions: Vec<FormRecoverySuggestion>,
    /// Current value that caused the error
    pub current_value: Option<String>,
    /// Expected format or value
    pub expected_format: Option<String>,
    /// Additional metadata for debugging
    pub metadata: HashMap<String, String>,
}

impl FormError {
    pub fn new(field: String, message: String) -> Self {
        Self {
            field: field.clone(),
            message,
            severity: FormErrorSeverity::default(),
            source: FormErrorSource::new(field),
            suggestions: Vec::new(),
            current_value: None,
            expected_format: None,
            metadata: HashMap::new(),
        }
    }

    pub fn with_severity(mut self, severity: FormErrorSeverity) -> Self {
        self.severity = severity;
        self
    }

    pub fn with_source(mut self, source: FormErrorSource) -> Self {
        self.source = source;
        self
    }

    pub fn with_suggestion(mut self, suggestion: FormRecoverySuggestion) -> Self {
        self.suggestions.push(suggestion);
        self
    }

    pub fn with_current_value(mut self, value: String) -> Self {
        self.current_value = Some(value);
        self
    }

    pub fn with_expected_format(mut self, format: String) -> Self {
        self.expected_format = Some(format);
        self
    }

    pub fn with_metadata(mut self, key: String, value: String) -> Self {
        self.metadata.insert(key, value);
        self
    }

    pub fn display_message(&self) -> String {
        format!("{}: {}", self.field, self.message)
    }

    pub fn debug_details(&self) -> String {
        let mut output = String::new();
        output.push_str(&format!("Field: {}\n", self.field));
        output.push_str(&format!("Severity: {:?}\n", self.severity));
        output.push_str(&format!("Message: {}\n", self.message));
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

/// Form validation result with enhanced context
#[derive(Clone, Debug)]
pub struct FormValidation {
    pub is_valid: bool,
    pub errors: Vec<FormError>,
    /// Validation timestamp
    pub validated_at: Option<chrono::DateTime<chrono::Utc>>,
    /// Form identifier
    pub form_id: Option<String>,
}

impl FormValidation {
    pub fn new() -> Self {
        Self {
            is_valid: true,
            errors: Vec::new(),
            validated_at: None,
            form_id: None,
        }
    }

    pub fn add_error(&mut self, field: impl Into<String>, message: impl Into<String>) {
        self.is_valid = false;
        self.errors.push(FormError::new(field.into(), message.into()));
    }

    /// Add an error with enhanced context
    pub fn add_error_with_context(&mut self, error: FormError) {
        self.is_valid = false;
        self.errors.push(error);
    }

    pub fn get_error(&self, field: &str) -> Option<&str> {
        self.errors
            .iter()
            .find(|error| error.field == field)
            .map(|error| error.message.as_str())
    }

    /// Get full error with context
    pub fn get_error_with_context(&self, field: &str) -> Option<&FormError> {
        self.errors.iter().find(|error| error.field == field)
    }

    /// Get errors by severity level
    pub fn errors_by_severity(&self, severity: FormErrorSeverity) -> Vec<&FormError> {
        self.errors.iter()
            .filter(|error| error.severity == severity)
            .collect()
    }

    /// Get critical errors that block submission
    pub fn critical_errors(&self) -> Vec<&FormError> {
        self.errors_by_severity(FormErrorSeverity::Critical)
    }

    /// Get all error messages for display
    pub fn all_error_messages(&self) -> Vec<String> {
        self.errors.iter()
            .map(|error| error.display_message())
            .collect()
    }

    /// Get a validation summary
    pub fn summary(&self) -> FormValidationSummary {
        let total_errors = self.errors.len();
        let critical_errors = self.critical_errors().len();
        let warning_errors = self.errors_by_severity(FormErrorSeverity::Warning).len();

        FormValidationSummary {
            is_valid: self.is_valid,
            total_errors,
            critical_errors,
            warning_errors,
        }
    }
}

impl Default for FormValidation {
    fn default() -> Self {
        Self::new()
    }
}

/// Summary of form validation state
#[derive(Clone, Debug, PartialEq)]
pub struct FormValidationSummary {
    pub is_valid: bool,
    pub total_errors: usize,
    pub critical_errors: usize,
    pub warning_errors: usize,
}

impl FormValidationSummary {
    pub fn status_message(&self) -> String {
        if self.is_valid {
            "Form is valid and ready to submit".to_string()
        } else if self.critical_errors > 0 {
            format!("{} critical error(s) must be fixed before submission", self.critical_errors)
        } else {
            format!("{} error(s) need attention", self.total_errors)
        }
    }
}

/// Submission error context for debugging form submission failures
#[derive(Clone, Debug)]
pub struct SubmissionErrorContext {
    /// Error message
    pub message: String,
    /// Technical details
    pub technical_details: Option<String>,
    /// HTTP status code (if applicable)
    pub status_code: Option<u16>,
    /// Network error details
    pub network_error: Option<String>,
    /// Server response (if available)
    pub server_response: Option<String>,
    /// Submission timestamp
    pub timestamp: Option<chrono::DateTime<chrono::Utc>>,
    /// Form data that was being submitted
    pub submitted_data: Option<HashMap<String, String>>,
    /// Endpoint URL
    pub endpoint: Option<String>,
    /// Recovery suggestions
    pub recovery_suggestions: Vec<FormRecoverySuggestion>,
}

impl SubmissionErrorContext {
    pub fn new(message: String) -> Self {
        Self {
            message,
            technical_details: None,
            status_code: None,
            network_error: None,
            server_response: None,
            timestamp: Some(chrono::Utc::now()),
            submitted_data: None,
            endpoint: None,
            recovery_suggestions: Vec::new(),
        }
    }

    pub fn with_technical_details(mut self, details: String) -> Self {
        self.technical_details = Some(details);
        self
    }

    pub fn with_status_code(mut self, code: u16) -> Self {
        self.status_code = Some(code);
        self
    }

    pub fn with_network_error(mut self, error: String) -> Self {
        self.network_error = Some(error);
        self
    }

    pub fn with_server_response(mut self, response: String) -> Self {
        self.server_response = Some(response);
        self
    }

    pub fn with_submitted_data(mut self, data: HashMap<String, String>) -> Self {
        self.submitted_data = Some(data);
        self
    }

    pub fn with_endpoint(mut self, endpoint: String) -> Self {
        self.endpoint = Some(endpoint);
        self
    }

    pub fn with_suggestion(mut self, suggestion: FormRecoverySuggestion) -> Self {
        self.recovery_suggestions.push(suggestion);
        self
    }

    pub fn user_message(&self) -> String {
        if let Some(status) = self.status_code {
            match status {
                400..=499 => format!("Client error: {}", self.message),
                500..=599 => format!("Server error: {}", self.message),
                _ => self.message.clone(),
            }
        } else if self.network_error.is_some() {
            format!("Network error: {}", self.message)
        } else {
            self.message.clone()
        }
    }

    pub fn debug_summary(&self) -> String {
        let mut output = String::new();
        output.push_str(&format!("Message: {}\n", self.message));
        if let Some(status) = self.status_code {
            output.push_str(&format!("Status Code: {}\n", status));
        }
        if let Some(endpoint) = &self.endpoint {
            output.push_str(&format!("Endpoint: {}\n", endpoint));
        }
        if let Some(technical) = &self.technical_details {
            output.push_str(&format!("Technical Details: {}\n", technical));
        }
        if let Some(network) = &self.network_error {
            output.push_str(&format!("Network Error: {}\n", network));
        }
        if let Some(response) = &self.server_response {
            output.push_str(&format!("Server Response: {}\n", response));
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
        if let Some(data) = &self.submitted_data {
            output.push_str("Submitted Data:\n");
            for (key, value) in data {
                output.push_str(&format!("  {}: {}\n", key, value));
            }
        }
        output
    }
}

/// Default theme Form component
#[component]
pub fn Form(
    #[prop(into, optional)] on_submit: Option<Callback<FormData>>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    let (_validation, _set_validation) = signal(FormValidation::new());
    
    let handle_submit = move |event: SubmitEvent| {
        event.prevent_default();
        
        if let Some(target) = event.target() {
            if let Ok(form) = target.dyn_into::<HtmlFormElement>() {
                let form_data = FormData::from_form(&form);
                
                if let Some(callback) = on_submit.as_ref() {
                    callback.run(form_data);
                }
            }
        }
    };
    
    let computed_class = Signal::derive(move || {
        let base_class = "space-y-6";
        if let Some(class) = class.get() {
            format!("{} {}", base_class, class)
        } else {
            base_class.to_string()
        }
    });
    
    view! {
        <form
            class=computed_class
            style=move || style.get().to_string()
            on:submit=handle_submit
            role="form"
            aria-labelledby="form-title"
            aria-describedby="form-description"
        >
            {children.map(|c| c())}
        </form>
    }
}

/// Form field wrapper component
#[component]
pub fn FormField(
    #[prop(into)] name: String,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(into, optional)] invalid: Signal<bool>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    let computed_class = Signal::derive(move || {
        let base_class = "space-y-2";
        let invalid_class = if invalid.get() { " data-invalid" } else { "" };
        let custom_class = class.get().unwrap_or_default();
        format!("{}{} {}", base_class, invalid_class, custom_class)
    });
    
    view! {
        <div
            class=computed_class
            style=move || style.get().to_string()
            data-field=name
            data-invalid=move || invalid.get().to_string()
            aria-invalid=move || invalid.get().to_string()
        >
            {children.map(|c| c())}
        </div>
    }
}

/// Form item wrapper component
#[component]
pub fn FormItem(
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    let computed_class = Signal::derive(move || {
        let base_class = "space-y-2";
        if let Some(class) = class.get() {
            format!("{} {}", base_class, class)
        } else {
            base_class.to_string()
        }
    });
    
    view! {
        <div
            class=computed_class
            style=move || style.get().to_string()
        >
            {children.map(|c| c())}
        </div>
    }
}

/// Form label component
#[component]
pub fn FormLabel(
    #[prop(into)] for_field: String,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    let computed_class = Signal::derive(move || {
        let base_class = "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70";
        if let Some(class) = class.get() {
            format!("{} {}", base_class, class)
        } else {
            base_class.to_string()
        }
    });
    
    view! {
        <label
            for=for_field
            class=computed_class
            style=move || style.get().to_string()
        >
            {children.map(|c| c())}
        </label>
    }
}

/// Form control wrapper component
#[component]
pub fn FormControl(
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    let computed_class = Signal::derive(move || {
        let base_class = "peer";
        if let Some(class) = class.get() {
            format!("{} {}", base_class, class)
        } else {
            base_class.to_string()
        }
    });
    
    view! {
        <div
            class=computed_class
            style=move || style.get().to_string()
        >
            {children.map(|c| c())}
        </div>
    }
}

/// Form message component for displaying validation errors
#[component]
pub fn FormMessage(
    #[prop(into, optional)] message: MaybeProp<String>,
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
) -> impl IntoView {
    let computed_class = Signal::derive(move || {
        let base_class = "text-sm font-medium text-destructive";
        if let Some(class) = class.get() {
            format!("{} {}", base_class, class)
        } else {
            base_class.to_string()
        }
    });
    
    view! {
        <p
            class=move || {
                if let Some(_message) = message.get() {
                    computed_class.get()
                } else {
                    "hidden".to_string()
                }
            }
            style=move || style.get().to_string()
            role="alert"
            aria-live="polite"
        >
            {move || message.get().unwrap_or_default()}
        </p>
    }
}

/// Form description component
#[component]
pub fn FormDescription(
    #[prop(into, optional)] class: MaybeProp<String>,
    #[prop(into, optional)] style: Signal<Style>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    let computed_class = Signal::derive(move || {
        let base_class = "text-sm text-muted-foreground";
        if let Some(class) = class.get() {
            format!("{} {}", base_class, class)
        } else {
            base_class.to_string()
        }
    });
    
    view! {
        <p
            class=computed_class
            style=move || style.get().to_string()
            id="form-description"
        >
            {children.map(|c| c())}
        </p>
    }
}

/// Form data structure for handling form submissions
#[derive(Clone, Debug)]
pub struct FormData {
    pub fields: std::collections::HashMap<String, String>,
}

impl FormData {
    pub fn new() -> Self {
        Self {
            fields: std::collections::HashMap::new(),
        }
    }

    pub fn from_form(form: &HtmlFormElement) -> Self {
        let mut form_data = Self::new();
        
        // Get all form elements
        let elements = form.elements();
        for i in 0..elements.length() {
            if let Some(element) = elements.get_with_index(i) {
                if let Ok(input) = element.dyn_into::<HtmlInputElement>() {
                    let name = input.name();
                    let value = input.value();
                    
                    if !name.is_empty() {
                        form_data.fields.insert(name, value);
                    }
                }
            }
        }
        
        form_data
    }

    pub fn get(&self, field: &str) -> Option<&String> {
        self.fields.get(field)
    }

    pub fn get_or_default(&self, field: &str) -> String {
        self.fields.get(field).cloned().unwrap_or_default()
    }
}
