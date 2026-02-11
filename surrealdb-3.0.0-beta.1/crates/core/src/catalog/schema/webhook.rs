//! Webhook definition stored in the catalogue

use crate::kvs::KVValue;
use crate::val::Value;
use crate::expr::statements::info::InfoStructure;
use lyxal_revision::lyxal_revisioned;
use serde::{Deserialize, Serialize};
use surrealdb_types::{SqlFormat, ToSql};

/// Persistent webhook definition stored in KVS catalogue
#[lyxal_revisioned(lyxal_revision = 3)]
#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct WebhookDefinition {
    /// Unique name of the webhook
    pub name: String,
    /// Path pattern to match (e.g., "/webhooks/stripe")
    pub path: String,
    /// HTTP methods (GET, POST, PUT, DELETE, PATCH, HEAD)
    pub methods: Vec<String>,
    /// Authentication type (none, basic, bearer, header:X-Api-Key, jwt)
    pub auth_type: String,
    /// Credential reference for authentication
    pub auth_credential: Option<String>,
    /// Verification mode (none, hmac, stripe, rsa, custom)
    pub verify: String,
    /// Secret expression for signature verification
    pub secret: Option<String>,
    /// Content type for payload parsing (json, raw, form, binary)
    pub content_type: String,
    /// Handler: "fn::path::to::function" or "event::name"
    pub handler: String,
    /// Response mode (immediate, handler, streaming)
    pub respond: String,
    /// Default response code
    pub response_code: Option<u16>,
    /// Custom response headers
    pub response_headers: Option<std::collections::BTreeMap<String, String>>,
    /// IP Whitelist
    pub whitelist: Option<Vec<String>>,
    /// Options
    pub ignore_bots: bool,
    /// Whether to provide raw body
    pub raw_body: bool,
    /// Whether the webhook is enabled
    pub enabled: bool,
    /// Optional comment
    pub comment: Option<String>,
}

impl KVValue for WebhookDefinition {
    fn kv_encode_value(&self) -> anyhow::Result<Vec<u8>> {
        Ok(lyxal_revision::to_vec(self)?)
    }

    fn kv_decode_value(bytes: Vec<u8>) -> anyhow::Result<Self> {
        Ok(lyxal_revision::from_slice(&bytes)?)
    }
}

impl InfoStructure for WebhookDefinition {
    fn structure(self) -> Value {
        Value::from(map! {
            "name".to_string() => self.name.into(),
            "path".to_string() => self.path.into(),
            "methods".to_string() => Value::from(self.methods.into_iter().map(Value::from).collect::<Vec<_>>()),
            "auth_type".to_string() => self.auth_type.into(),
            "auth_credential".to_string() => self.auth_credential.map(|_| Value::from("[REDACTED]")).unwrap_or(Value::None),
            "verify".to_string() => self.verify.into(),
            "secret".to_string() => self.secret.map(|_| Value::from("[REDACTED]")).unwrap_or(Value::None),
            "content_type".to_string() => self.content_type.into(),
            "handler".to_string() => self.handler.into(),
            "respond".to_string() => self.respond.into(),
            "response_code".to_string() => self.response_code.map(Into::into).unwrap_or(Value::None),
            "response_headers".to_string() => self.response_headers.map(|h| Value::from(h.into_iter().map(|(k, v)| (k, v.into())).collect::<std::collections::BTreeMap<_, _>>())).unwrap_or(Value::None),
            "whitelist".to_string() => self.whitelist.map(|w| Value::from(w.into_iter().map(Value::from).collect::<Vec<_>>())).unwrap_or(Value::None),
            "ignore_bots".to_string() => self.ignore_bots.into(),
            "raw_body".to_string() => self.raw_body.into(),
            "enabled".to_string() => self.enabled.into(),
            "comment".to_string() => self.comment.map(Value::from).unwrap_or(Value::None),
        })
    }
}

impl ToSql for WebhookDefinition {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        f.push_str("DEFINE WEBHOOK ");
        f.push_str(&self.name);
        f.push_str(" ON PATH '");
        f.push_str(&self.path);
        f.push_str("'");
        f.push_str(" METHOD ");
        f.push_str(&self.methods.join(", "));
        // AUTH clause
        if self.auth_type != "none" {
            f.push_str(" AUTH ");
            f.push_str(&self.auth_type.to_uppercase());
            if self.auth_credential.is_some() {
                f.push_str(" CREDENTIAL [REDACTED]");
            }
        }
        // VERIFY clause
        if self.verify != "none" {
            f.push_str(" VERIFY ");
            f.push_str(&self.verify.to_uppercase());
        }
        if self.secret.is_some() {
            f.push_str(" SECRET [REDACTED]");
        }
        if self.content_type != "json" {
            f.push_str(" CONTENT TYPE ");
            f.push_str(&self.content_type.to_uppercase());
        }
        f.push_str(" HANDLER ");
        f.push_str(&self.handler);
        
        // Extended clauses
        if self.respond != "immediate" {
            f.push_str(" RESPOND ");
            f.push_str(&self.respond.to_uppercase());
        }
        if let Some(code) = self.response_code {
            f.push_str(" RESPONSE CODE ");
            f.push_str(&code.to_string());
        }
        if let Some(ref whitelist) = self.whitelist {
            f.push_str(" WHITELIST '");
            f.push_str(&whitelist.join(", "));
            f.push_str("'");
        }
        
        if !self.enabled {
            f.push_str(" DISABLED");
        }
        if let Some(ref comment) = self.comment {
            f.push_str(" COMMENT '");
            f.push_str(comment);
            f.push_str("'");
        }
    }
}

impl Default for WebhookDefinition {
    fn default() -> Self {
        Self {
            name: String::new(),
            path: String::new(),
            methods: vec!["POST".to_string()],
            auth_type: "none".to_string(),
            auth_credential: None,
            verify: "none".to_string(),
            secret: None,
            content_type: "json".to_string(),
            handler: String::new(),
            respond: "immediate".to_string(),
            response_code: None,
            response_headers: None,
            whitelist: None,
            ignore_bots: false,
            raw_body: false,
            enabled: true,
            comment: None,
        }
    }
}
