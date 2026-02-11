//! New York-themed implementation of the Error Handling system
//!
//! This module provides the New York style variant of error boundary components.
//! The New York style follows the design system conventions from shadcn/ui's New York theme.

pub use super::*;

// Re-export the main components for easy access
pub use super::{
    ErrorBoundary,
    RichErrorBoundary,
    ErrorFallback,
    RichErrorFallback,
    ErrorInfo,
    ErrorContext,
    ErrorSeverity,
    use_error_handler,
    use_rich_error_handler,
    create_user_error,
    handle_error,
    create_rich_error,
    create_error_with_severity,
    handle_error_with_context,
    wrap_error_with_context,
    ErrorContextBuilder,
    ErrorSource,
    RecoverySuggestion,
};

// New York style classes for the error fallback
pub const ERROR_FALLBACK_CLASSES: &str = "ny-error-fallback";
pub const ERROR_CONTENT_CLASSES: &str = "ny-error-content";
pub const ERROR_ICON_CLASSES: &str = "ny-error-icon";
pub const ERROR_TITLE_CLASSES: &str = "ny-error-title";
pub const ERROR_MESSAGE_CLASSES: &str = "ny-error-message";
pub const ERROR_ACTIONS_CLASSES: &str = "ny-error-actions";
pub const ERROR_RETRY_CLASSES: &str = "ny-error-retry";

// New York style error messages
pub const DEFAULT_ERROR_TITLE: &str = "Something went wrong";
pub const DEFAULT_ERROR_MESSAGE: &str = "An unexpected error occurred. Please try refreshing the page.";
pub const DEFAULT_RETRY_TEXT: &str = "Try Again";

// New York style error icons
pub const DEFAULT_ERROR_ICON: &str = "!";
pub const DEFAULT_ERROR_ICON_ALT: &str = "Error icon";

// Error handling configuration
pub const DEFAULT_LOG_ERRORS: bool = true;
pub const DEFAULT_SHOW_TECHNICAL_DETAILS: bool = false;

// New York style error fallback styling constants
pub const ERROR_FALLBACK_STYLES: &str = r#"
    .ny-error-fallback {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 200px;
        padding: 2rem;
        background-color: hsl(var(--destructive) / 0.1);
        border: 1px solid hsl(var(--destructive) / 0.2);
        border-radius: 0.5rem;
        margin: 1rem 0;
    }

    .ny-error-content {
        text-align: center;
        max-width: 500px;
    }

    .ny-error-icon {
        font-size: 3rem;
        margin-bottom: 1rem;
        color: hsl(var(--destructive));
        font-weight: bold;
    }

    .ny-error-title {
        font-size: 1.5rem;
        font-weight: 600;
        color: hsl(var(--destructive));
        margin-bottom: 0.5rem;
    }

    .ny-error-message {
        color: hsl(var(--muted-foreground));
        margin-bottom: 1.5rem;
        line-height: 1.5;
    }

    .ny-error-actions {
        display: flex;
        justify-content: center;
    }

    .ny-error-retry {
        padding: 0.5rem 1rem;
        border: none;
        border-radius: 0.375rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        background-color: hsl(var(--primary));
        color: hsl(var(--primary-foreground));
    }

    .ny-error-retry:hover {
        background-color: hsl(var(--primary) / 0.9);
    }
"#;
