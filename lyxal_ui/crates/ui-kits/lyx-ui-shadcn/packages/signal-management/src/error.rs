//! Error types for signal management operations
//!
//! This module provides comprehensive error types with enhanced debugging context,
//! including source location tracking, error chaining, and recovery suggestions.

use std::collections::HashMap;
use thiserror::Error;

/// Error severity level for signal management errors
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum ErrorSeverity {
/// Informational message
Info,
/// Warning that might cause issues
Warning,
/// Error that prevents operation
Error,
/// Critical error that needs immediate attention
Critical,
}

impl Default for ErrorSeverity {
fn default() -> Self {
Self::Error
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

/// Recovery suggestion for signal management errors
#[derive(Clone, Debug)]
pub struct RecoverySuggestion {
/// User-friendly action to take
pub action: String,
/// Detailed explanation of why this might help
pub explanation: Option<String>,
/// Whether this suggestion is automatic
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

/// Enhanced error context for signal management errors
#[derive(Clone, Debug)]
pub struct SignalErrorContext {
/// Error message
pub message: String,
/// Technical details
pub technical_details: Option<String>,
/// Severity level
pub severity: ErrorSeverity,
/// Source location
pub source: ErrorSource,
/// Recovery suggestions
pub recovery_suggestions: Vec<RecoverySuggestion>,
/// Additional metadata
pub metadata: HashMap<String, String>,
/// Underlying cause (for error chaining)
pub cause: Option<String>,
/// Error code for categorization
pub error_code: Option<String>,
/// Related signal ID (if applicable)
pub signal_id: Option<String>,
}

impl SignalErrorContext {
/// Create a new error context
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
signal_id: None,
}
}

/// Set technical details
pub fn with_technical_details(mut self, details: String) -> Self {
self.technical_details = Some(details);
self
}

/// Set severity level
pub fn with_severity(mut self, severity: ErrorSeverity) -> Self {
self.severity = severity;
self
}

/// Set source location
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

/// Set underlying cause
pub fn with_cause(mut self, cause: String) -> Self {
self.cause = Some(cause);
self
}

/// Set error code
pub fn with_error_code(mut self, code: String) -> Self {
self.error_code = Some(code);
self
}

/// Set signal ID
pub fn with_signal_id(mut self, id: String) -> Self {
self.signal_id = Some(id);
self
}

/// Get a formatted display string
pub fn display(&self) -> String {
let mut output = self.message.clone();
if let Some(error_code) = &self.error_code {
output.push_str(&format!(" [{}]", error_code));
}
if let Some(signal_id) = &self.signal_id {
output.push_str(&format!(" (Signal: {})", signal_id));
}
output
}

/// Get a detailed debugging string
pub fn debug_string(&self) -> String {
let mut output = String::new();
output.push_str(&format!("Severity: {:?}\n", self.severity));
output.push_str(&format!("Message: {}\n", self.message));
if let Some(error_code) = &self.error_code {
output.push_str(&format!("Error Code: {}\n", error_code));
}
if let Some(signal_id) = &self.signal_id {
output.push_str(&format!("Signal ID: {}\n", signal_id));
}
if let Some(technical) = &self.technical_details {
output.push_str(&format!("Technical Details: {}\n", technical));
}
if let Some(cause) = &self.cause {
output.push_str(&format!("Cause: {}\n", cause));
}
if self.source.file.is_some() {
output.push_str(&format!("Source: {}\n", self.source.file.as_ref().unwrap()));
if let Some(line) = self.source.line {
output.push_str(&format!("  Line: {}\n", line));
}
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
}

impl std::fmt::Display for SignalErrorContext {
fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
write!(f, "{}", self.display())
}
}

impl std::error::Error for SignalErrorContext {}

/// Errors that can occur during signal management operations
#[derive(Error, Debug, Clone, PartialEq)]
pub enum SignalManagementError {
/// Signal has been disposed and is no longer valid
#[error("Signal has been disposed and is no longer valid")]
SignalDisposed {
/// Error context with debugging information
context: Option<SignalErrorContext>,
},

/// Signal update failed due to invalid state
#[error("Signal update failed: {reason}")]
UpdateFailed {
/// Reason for failure
reason: String,
/// Error context with debugging information
context: Option<SignalErrorContext>,
},

/// Memory management operation failed
#[error("Memory management operation failed: {reason}")]
MemoryManagementFailed {
/// Reason for failure
reason: String,
/// Error context with debugging information
context: Option<SignalErrorContext>,
},

/// Batched update operation failed
#[error("Batched update operation failed: {reason}")]
BatchedUpdateFailed {
/// Reason for failure
reason: String,
/// Error context with debugging information
context: Option<SignalErrorContext>,
},

/// Group not found error
#[error("Group not found: {group_name}")]
GroupNotFound {
/// Name of the group that was not found
group_name: String,
/// Error context with debugging information
context: Option<SignalErrorContext>,
},

/// Signal operation error
#[error("Signal error: {0}")]
SignalError(String, Option<SignalErrorContext>),

/// Memo operation error
#[error("Memo error: {0}")]
MemoError(String, Option<SignalErrorContext>),

/// Cleanup operation error
#[error("Cleanup error: {0}")]
CleanupError(String, Option<SignalErrorContext>),

/// Memory operation error
#[error("Memory error: {0}")]
MemoryError(String, Option<SignalErrorContext>),

/// Batch operation error
#[error("Batch error: {0}")]
BatchError(String, Option<SignalErrorContext>),
}

impl SignalManagementError {
/// Create a new update failed error
#[track_caller]
pub fn update_failed(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("SIG_UPDATE_FAILED".to_string())
.with_severity(ErrorSeverity::Error)
.with_suggestion(
RecoverySuggestion::new("Check signal state before updating".to_string())
.with_explanation("The signal may have been disposed or is in an invalid state.".to_string())
);
Self::UpdateFailed {
reason: reason_str,
context: Some(context),
}
}

/// Create a new memory management failed error
#[track_caller]
pub fn memory_management_failed(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("SIG_MEMORY_FAILED".to_string())
.with_severity(ErrorSeverity::Critical)
.with_suggestion(
RecoverySuggestion::new("Check available memory".to_string())
.with_explanation("The system may be running low on memory resources.".to_string())
);
Self::MemoryManagementFailed {
reason: reason_str,
context: Some(context),
}
}

/// Create a new batched update failed error
#[track_caller]
pub fn batched_update_failed(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("SIG_BATCH_FAILED".to_string())
.with_severity(ErrorSeverity::Error)
.with_suggestion(
RecoverySuggestion::new("Retry the batch operation".to_string())
.with_explanation("The batch may have been interrupted by another operation.".to_string())
);
Self::BatchedUpdateFailed {
reason: reason_str,
context: Some(context),
}
}

/// Create a new group not found error
#[track_caller]
pub fn group_not_found(group_name: impl Into<String>) -> Self {
let group_name_str = group_name.into();
let context = SignalErrorContext::new(format!("Group '{}' not found", group_name_str.clone()))
.with_error_code("SIG_GROUP_NOT_FOUND".to_string())
.with_severity(ErrorSeverity::Warning)
.with_metadata("group_name".to_string(), group_name_str.clone())
.with_suggestion(
RecoverySuggestion::new(format!("Create the '{}' group first", group_name_str))
.with_explanation("The group must be created before signals can be added to it.".to_string())
);
Self::GroupNotFound {
group_name: group_name_str,
context: Some(context),
}
}

/// Create a new signal disposed error
#[track_caller]
pub fn signal_disposed() -> Self {
let context = SignalErrorContext::new(
"Signal has been disposed and is no longer valid".to_string()
)
.with_error_code("SIG_DISPOSED".to_string())
.with_severity(ErrorSeverity::Warning)
.with_suggestion(
RecoverySuggestion::new("Create a new signal".to_string())
.with_explanation("Once disposed, a signal cannot be recovered. Create a new signal instance.".to_string())
);
Self::SignalDisposed {
context: Some(context),
}
}

/// Create a new signal error
#[track_caller]
pub fn signal_error(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("SIG_ERROR".to_string())
.with_severity(ErrorSeverity::Error);
Self::SignalError(reason_str, Some(context))
}

/// Create a new memo error
#[track_caller]
pub fn memo_error(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("MEMO_ERROR".to_string())
.with_severity(ErrorSeverity::Error)
.with_suggestion(
RecoverySuggestion::new("Check memo dependencies".to_string())
.with_explanation("Memo dependencies may be invalid or disposed.".to_string())
);
Self::MemoError(reason_str, Some(context))
}

/// Create a new cleanup error
#[track_caller]
pub fn cleanup_error(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("CLEANUP_ERROR".to_string())
.with_severity(ErrorSeverity::Warning);
Self::CleanupError(reason_str, Some(context))
}

/// Create a new memory error
#[track_caller]
pub fn memory_error(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("MEMORY_ERROR".to_string())
.with_severity(ErrorSeverity::Critical);
Self::MemoryError(reason_str, Some(context))
}

/// Create a new batch error
#[track_caller]
pub fn batch_error(reason: impl Into<String>) -> Self {
let reason_str = reason.into();
let context = SignalErrorContext::new(reason_str.clone())
.with_error_code("BATCH_ERROR".to_string())
.with_severity(ErrorSeverity::Error);
Self::BatchError(reason_str, Some(context))
}

/// Get the error context if available
pub fn context(&self) -> Option<&SignalErrorContext> {
match self {
Self::SignalDisposed { context } => context.as_ref(),
Self::UpdateFailed { context, .. } => context.as_ref(),
Self::MemoryManagementFailed { context, .. } => context.as_ref(),
Self::BatchedUpdateFailed { context, .. } => context.as_ref(),
Self::GroupNotFound { context, .. } => context.as_ref(),
Self::SignalError(_, context) => context.as_ref(),
Self::MemoError(_, context) => context.as_ref(),
Self::CleanupError(_, context) => context.as_ref(),
Self::MemoryError(_, context) => context.as_ref(),
Self::BatchError(_, context) => context.as_ref(),
}
}

/// Get detailed debug information
pub fn debug_details(&self) -> String {
if let Some(context) = self.context() {
context.debug_string()
} else {
format!("{}", self)
}
}

/// Get the error code if available
pub fn error_code(&self) -> Option<&str> {
self.context().and_then(|c| c.error_code.as_deref())
}

/// Get the severity level
pub fn severity(&self) -> ErrorSeverity {
self.context()
.map(|c| c.severity)
.unwrap_or(ErrorSeverity::Error)
}

/// Get recovery suggestions
pub fn recovery_suggestions(&self) -> Vec<&RecoverySuggestion> {
self.context()
.map(|c| c.recovery_suggestions.iter().collect())
.unwrap_or_default()
}

/// Wrap this error with additional context
#[track_caller]
pub fn with_context(mut self, additional_message: String) -> Self {
let mut new_context = SignalErrorContext::new(additional_message)
.with_cause(self.to_string())
.with_severity(self.severity());

if let Some(original_context) = self.context() {
if let Some(error_code) = &original_context.error_code {
new_context = new_context.with_error_code(format!("WRAPPED_{}", error_code));
}
if let Some(signal_id) = &original_context.signal_id {
new_context = new_context.with_signal_id(signal_id.clone());
}
}

// Update the error variant with new context
match self {
Self::SignalDisposed { .. } => {
Self::SignalDisposed { context: Some(new_context) }
}
Self::UpdateFailed { reason, .. } => {
Self::UpdateFailed { reason, context: Some(new_context) }
}
Self::MemoryManagementFailed { reason, .. } => {
Self::MemoryManagementFailed { reason, context: Some(new_context) }
}
Self::BatchedUpdateFailed { reason, .. } => {
Self::BatchedUpdateFailed { reason, context: Some(new_context) }
}
Self::GroupNotFound { group_name, .. } => {
Self::GroupNotFound { group_name, context: Some(new_context) }
}
Self::SignalError(msg, _) => {
Self::SignalError(msg, Some(new_context))
}
Self::MemoError(msg, _) => {
Self::MemoError(msg, Some(new_context))
}
Self::CleanupError(msg, _) => {
Self::CleanupError(msg, Some(new_context))
}
Self::MemoryError(msg, _) => {
Self::MemoryError(msg, Some(new_context))
}
Self::BatchError(msg, _) => {
Self::BatchError(msg, Some(new_context))
}
}
}

/// Set the signal ID for this error
pub fn with_signal_id(mut self, signal_id: String) -> Self {
// Update the context within the error variant
match &mut self {
Self::SignalDisposed { context } => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::UpdateFailed { context, .. } => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::MemoryManagementFailed { context, .. } => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::BatchedUpdateFailed { context, .. } => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::GroupNotFound { context, .. } => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::SignalError(_, context) => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::MemoError(_, context) => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::CleanupError(_, context) => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::MemoryError(_, context) => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
Self::BatchError(_, context) => {
if let Some(ctx) = context {
ctx.signal_id = Some(signal_id);
}
}
}
self
}
}
