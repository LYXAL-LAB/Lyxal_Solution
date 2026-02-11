pub mod email;
pub mod sms;

pub use email::{EmailConnector, SmtpConfig, SmtpConnector};
pub use sms::{GenericSmsConnector, SmsConfig, SmsConnector};

/// Common trait for all notification-based connectors
pub trait NotificationConnector: crate::base::Connector {
    // Shared functionality for notification connectors can be added here
}
