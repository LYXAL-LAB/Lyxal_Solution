//! DEFINE WEBHOOK statement
//!
//! Syntax:
//! ```sql
//! DEFINE WEBHOOK [IF NOT EXISTS | OVERWRITE] <name>
//!   ON PATH <string>
//!   [METHOD <GET|POST|PUT|DELETE|PATCH>]
//!   [VERIFY <NONE|HMAC|STRIPE|RSA|custom>]
//!   [SECRET <expr>]
//!   [CONTENT TYPE <JSON|RAW|FORM|BINARY>]
//!   HANDLER <fn::path | EVENT name>
//!   [ENABLED | DISABLED]
//!   [COMMENT <string>];
//! ```

use anyhow::Result;
use reblessive::tree::Stk;
use std::fmt::{self, Display};

use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::expr::{Expr, FlowResultExt};
use crate::expr::parameterize::expr_to_ident;
use crate::expr::statements::define::DefineKind;
use crate::iam::{Action, ResourceKind};
use crate::val::Value;
use crate::catalog::providers::{NamespaceProvider, DatabaseProvider};

/// Verification mode for webhook signatures
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub enum WebhookVerify {
    #[default]
    None,
    Hmac,
    Stripe,
    Rsa,
    Custom(String),
}

impl Display for WebhookVerify {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::None => write!(f, "NONE"),
            Self::Hmac => write!(f, "HMAC"),
            Self::Stripe => write!(f, "STRIPE"),
            Self::Rsa => write!(f, "RSA"),
            Self::Custom(s) => write!(f, "{}", s),
        }
    }
}

/// Content type for webhook payload parsing
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub enum WebhookContentType {
    #[default]
    Json,
    Raw,
    Form,
    Binary,
}

impl Display for WebhookContentType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::Json => write!(f, "JSON"),
            Self::Raw => write!(f, "RAW"),
            Self::Form => write!(f, "FORM"),
            Self::Binary => write!(f, "BINARY"),
        }
    }
}

/// Authentication type for webhook endpoint
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub enum WebhookAuth {
    /// No authentication required
    #[default]
    None,
    /// Basic authentication (username:password)
    Basic,
    /// Bearer token authentication
    Bearer,
    /// Custom header authentication
    Header(String),
    /// JWT authentication
    Jwt,
}

impl Display for WebhookAuth {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::None => write!(f, "NONE"),
            Self::Basic => write!(f, "BASIC"),
            Self::Bearer => write!(f, "BEARER"),
            Self::Header(h) => write!(f, "HEADER {}", h),
            Self::Jwt => write!(f, "JWT"),
        }
    }
}

/// Response mode for webhooks
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub enum WebhookResponseMode {
    /// Respond immediately with 200 OK
    #[default]
    Immediate,
    /// Respond with the result of the handler
    Handler,
    /// Response is handled by a streaming channel (v2.1+)
    Streaming,
}

impl Display for WebhookResponseMode {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::Immediate => write!(f, "IMMEDIATE"),
            Self::Handler => write!(f, "HANDLER"),
            Self::Streaming => write!(f, "STREAMING"),
        }
    }
}

/// Advanced options for webhooks
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub struct WebhookOptions {
    pub ignore_bots: bool,
    pub raw_body: bool,
    pub binary_property: Option<String>,
}

impl Display for WebhookOptions {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "OPTIONS {{ ignore_bots: {}, raw_body: {} }}", self.ignore_bots, self.raw_body)
    }
}

/// Handler type for webhook execution
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub enum WebhookHandler {
    /// Call a function: fn::namespace::function
    Function(Expr),
    /// Trigger an event: EVENT name
    Event(Expr),
}

impl Display for WebhookHandler {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Self::Function(e) => write!(f, "fn::{:?}", e),
            Self::Event(s) => write!(f, "EVENT {:?}", s),
        }
    }
}

/// DEFINE WEBHOOK statement AST
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefineWebhookStatement {
    pub kind: DefineKind,
    pub name: Expr,
    pub path: Expr,
    pub methods: Vec<String>,
    /// Authentication for the endpoint itself
    pub auth: WebhookAuth,
    /// Credential reference for auth (e.g., $credential.basic_creds)
    pub auth_credential: Option<Expr>,
    /// Signature verification mode
    pub verify: WebhookVerify,
    pub secret: Option<Expr>,
    pub content_type: WebhookContentType,
    pub handler: WebhookHandler,
    /// Response configuration
    pub respond: WebhookResponseMode,
    pub response_code: Option<u16>,
    pub response_headers: Option<std::collections::BTreeMap<String, String>>,
    /// IP Whitelist (comma-separated IPs or CIDRs)
    pub whitelist: Option<Vec<String>>,
    /// Advanced options
    pub options: WebhookOptions,
    pub enabled: bool,
    pub comment: Option<Expr>,
}

impl DefineWebhookStatement {
    /// Process this type returning a computed simple Value
    pub(crate) async fn compute(
        &self,
        stk: &mut Stk,
        ctx: &FrozenContext,
        opt: &Options,
        doc: Option<&CursorDoc>,
    ) -> Result<Value> {
        // Evaluate the name expression
        let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "webhook name").await?;

        // Evaluate the path expression
        let path = stk.run(|stk| self.path.compute(stk, ctx, opt, doc)).await.catch_return()?.to_raw_string();

        // Get namespace and database
        let (ns_name, db_name) = opt.ns_db()?;

        // Check permissions
        opt.is_allowed(Action::Edit, ResourceKind::Any, &crate::expr::Base::Db)?;

        // Get transaction
        let txn = ctx.tx();

        // Get NS/DB IDs for key construction
        let ns = txn.expect_ns_by_name(ns_name).await?;
        let db = txn.expect_db_by_name(ns_name, db_name).await?;

        // Create the webhook key
        let key = crate::key::database::wh::Wh::new(ns.namespace_id, db.database_id, &name);

        // Check if exists (for IF NOT EXISTS)
        if let DefineKind::IfNotExists = self.kind {
            if txn.exists(&key, None).await? {
                return Ok(Value::None);
            }
        }

        // Evaluate auth credential if present
        let auth_credential = if let Some(ref ac) = self.auth_credential {
            let v = stk.run(|stk| ac.compute(stk, ctx, opt, doc)).await.catch_return()?;
            Some(v.to_raw_string())
        } else {
            None
        };

        // Evaluate secret if present
        let secret = if let Some(ref s) = self.secret {
            let v = stk.run(|stk| s.compute(stk, ctx, opt, doc)).await.catch_return()?;
            Some(v.to_raw_string())
        } else {
            None
        };

        // Evaluate comment if present
        let comment = if let Some(ref c) = self.comment {
            let v = stk.run(|stk| c.compute(stk, ctx, opt, doc)).await.catch_return()?;
            Some(v.to_raw_string())
        } else {
            None
        };

        // Convert handler to string representation
        let handler_str = match &self.handler {
            WebhookHandler::Function(e) => {
                let v = stk.run(|stk| e.compute(stk, ctx, opt, doc)).await.catch_return()?;
                format!("fn::{}", v.to_raw_string())
            }
            WebhookHandler::Event(e) => {
                let v = stk.run(|stk| e.compute(stk, ctx, opt, doc)).await.catch_return()?;
                format!("event::{}", v.to_raw_string())
            }
        };

        // Create the definition for storage
        let val = crate::catalog::WebhookDefinition {
            name: name.clone(),
            path: path.clone(),
            methods: self.methods.clone(),
            auth_type: match &self.auth {
                WebhookAuth::None => "none".to_string(),
                WebhookAuth::Basic => "basic".to_string(),
                WebhookAuth::Bearer => "bearer".to_string(),
                WebhookAuth::Header(h) => format!("header:{}", h),
                WebhookAuth::Jwt => "jwt".to_string(),
            },
            auth_credential,
            verify: match &self.verify {
                WebhookVerify::None => "none".to_string(),
                WebhookVerify::Hmac => "hmac".to_string(),
                WebhookVerify::Stripe => "stripe".to_string(),
                WebhookVerify::Rsa => "rsa".to_string(),
                WebhookVerify::Custom(s) => s.clone(),
            },
            secret,
            content_type: match &self.content_type {
                WebhookContentType::Json => "json".to_string(),
                WebhookContentType::Raw => "raw".to_string(),
                WebhookContentType::Form => "form".to_string(),
                WebhookContentType::Binary => "binary".to_string(),
            },
            handler: handler_str,
            respond: match &self.respond {
                WebhookResponseMode::Immediate => "immediate".to_string(),
                WebhookResponseMode::Handler => "handler".to_string(),
                WebhookResponseMode::Streaming => "streaming".to_string(),
            },
            response_code: self.response_code,
            response_headers: self.response_headers.clone(),
            whitelist: self.whitelist.clone(),
            ignore_bots: self.options.ignore_bots,
            raw_body: self.options.raw_body,
            enabled: self.enabled,
            comment,
        };

        // Store the definition
        txn.set(&key, &val, None).await?;

        // Emit system event
        tracing::info!(
            event = "webhook:defined",
            name = %name,
            path = %path,
            methods = %self.methods.join(","),
            enabled = self.enabled,
            "Webhook defined"
        );

        Ok(Value::None)
    }
}

impl Display for DefineWebhookStatement {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "DEFINE WEBHOOK")?;
        match self.kind {
            DefineKind::Default => {}
            DefineKind::Overwrite => write!(f, " OVERWRITE")?,
            DefineKind::IfNotExists => write!(f, " IF NOT EXISTS")?,
        }
        write!(f, " {:?}", self.name)?;
        write!(f, " ON PATH {:?}", self.path)?;
        write!(f, " METHOD {}", self.methods.join(", "))?;
        // AUTH clause
        if self.auth != WebhookAuth::None {
            write!(f, " AUTH {}", self.auth)?;
            if let Some(ref cred) = self.auth_credential {
                write!(f, " CREDENTIAL {:?}", cred)?;
            }
        }
        // VERIFY clause (signature verification)
        if self.verify != WebhookVerify::None {
            write!(f, " VERIFY {}", self.verify)?;
        }
        if let Some(ref s) = self.secret {
            write!(f, " SECRET {:?}", s)?;
        }
        if self.content_type != WebhookContentType::Json {
            write!(f, " CONTENT TYPE {}", self.content_type)?;
        }
        write!(f, " HANDLER {}", self.handler)?;
        
        // RESPOND clause
        if self.respond != WebhookResponseMode::Immediate {
            write!(f, " RESPOND {}", self.respond)?;
        }
        if let Some(code) = self.response_code {
            write!(f, " RESPONSE CODE {}", code)?;
        }
        if let Some(ref headers) = self.response_headers {
            write!(f, " RESPONSE HEADERS {:?}", headers)?;
        }
        if let Some(ref whitelist) = self.whitelist {
            write!(f, " WHITELIST {:?}", whitelist)?;
        }
        if self.options != WebhookOptions::default() {
            write!(f, " {:?}", self.options)?;
        }
        
        if !self.enabled {
            write!(f, " DISABLED")?;
        }
        if let Some(ref c) = self.comment {
            write!(f, " COMMENT {:?}", c)?;
        }
        Ok(())
    }
}
