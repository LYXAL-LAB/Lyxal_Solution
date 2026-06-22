pub mod github;
pub mod google;
pub mod discord;
pub mod facebook;
pub mod apple;
pub mod linkedin;
pub mod gitlab;
pub mod slack;
pub mod wechat;
pub mod amazon;
pub mod azuread;
pub mod line;
pub mod alipay;
pub mod x;

use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use crate::base::{Connector, ConnectorMetadata, ConnectorType};
use lyxal_core::Result;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SocialUserInfo {
    pub id: String,
    pub username: Option<String>,
    pub email: Option<String>,
    pub name: Option<String>,
    pub avatar: Option<String>,
    pub raw_data: serde_json::Value,
}

#[async_trait]
pub trait SocialConnector: Connector {
    async fn get_authorization_url(&self, state: &str, redirect_uri: &str) -> Result<String>;
    async fn get_user_info(&self, code: &str, redirect_uri: &str) -> Result<SocialUserInfo>;
}
