pub mod mailchimp;
pub mod messagebird;

pub mod twilio;

pub mod vonage;

pub mod aliyun_sms;
pub mod aliyun_dm;

pub mod postmark;
pub mod gatewayapi;

pub mod mailgun;

pub mod aws_ses;

pub mod twilio;

pub mod sendgrid;

pub mod smtp;

use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use lyxal_core::Result;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum NotificationType {
    SignIn,
    Register,
    ForgotPassword,
    Generic,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotificationPayload {
    pub to: String,
    pub code: Option<String>,
    pub link: Option<String>,
    pub locale: String,
    pub notification_type: NotificationType,
}

#[async_trait]
pub trait NotificationConnector: Connector {
    async fn send(&self, payload: NotificationPayload) -> Result<bool>;
}
