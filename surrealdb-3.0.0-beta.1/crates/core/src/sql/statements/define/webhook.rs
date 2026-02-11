//! DEFINE WEBHOOK SQL statement

use surrealdb_types::{SqlFormat, ToSql, write_sql};
use super::DefineKind;
use crate::fmt::CoverStmts;
use crate::sql::Expr;

/// Verification mode for webhook signatures
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub enum WebhookVerify {
    #[default]
    None,
    Hmac,
    Stripe,
    Rsa,
    Custom(String),
}

impl ToSql for WebhookVerify {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        match self {
            Self::None => f.push_str("NONE"),
            Self::Hmac => f.push_str("HMAC"),
            Self::Stripe => f.push_str("STRIPE"),
            Self::Rsa => f.push_str("RSA"),
            Self::Custom(s) => f.push_str(s),
        }
    }
}

/// Content type for webhook payload
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub enum WebhookContentType {
    #[default]
    Json,
    Raw,
    Form,
    Binary,
}

impl ToSql for WebhookContentType {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        match self {
            Self::Json => f.push_str("JSON"),
            Self::Raw => f.push_str("RAW"),
            Self::Form => f.push_str("FORM"),
            Self::Binary => f.push_str("BINARY"),
        }
    }
}

/// Authentication type for webhook endpoint
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub enum WebhookAuth {
    #[default]
    None,
    Basic,
    Bearer,
    Header(String),
    Jwt,
}

impl ToSql for WebhookAuth {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        match self {
            Self::None => f.push_str("NONE"),
            Self::Basic => f.push_str("BASIC"),
            Self::Bearer => f.push_str("BEARER"),
            Self::Header(h) => {
                f.push_str("HEADER ");
                f.push_str(h);
            }
            Self::Jwt => f.push_str("JWT"),
        }
    }
}

/// Response mode for webhooks
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub enum WebhookResponseMode {
    #[default]
    Immediate,
    Handler,
    Streaming,
}

impl ToSql for WebhookResponseMode {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        match self {
            Self::Immediate => f.push_str("IMMEDIATE"),
            Self::Handler => f.push_str("HANDLER"),
            Self::Streaming => f.push_str("STREAMING"),
        }
    }
}

/// Advanced options for webhooks
#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct WebhookOptions {
    pub ignore_bots: bool,
    pub raw_body: bool,
}

impl ToSql for WebhookOptions {
    fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
        f.push_str("OPTIONS { ");
        f.push_str("ignore_bots: ");
        f.push_str(&self.ignore_bots.to_string());
        f.push_str(", raw_body: ");
        f.push_str(&self.raw_body.to_string());
        f.push_str(" }");
    }
}

/// Handler type for webhook execution
#[derive(Clone, Debug, Eq, PartialEq)]
pub enum WebhookHandler {
    Function(Expr),
    Event(Expr),
}

impl ToSql for WebhookHandler {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        match self {
            Self::Function(e) => e.fmt_sql(f, sql_fmt),
            Self::Event(e) => {
                f.push_str("EVENT ");
                e.fmt_sql(f, sql_fmt);
            }
        }
    }
}

/// DEFINE WEBHOOK statement SQL AST
#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct DefineWebhookStatement {
    pub kind: DefineKind,
    pub name: Expr,
    pub path: Expr,
    pub methods: Vec<String>,
    pub auth: WebhookAuth,
    pub auth_credential: Option<Expr>,
    pub verify: WebhookVerify,
    pub secret: Option<Expr>,
    pub content_type: WebhookContentType,
    pub handler: WebhookHandler,
    pub respond: WebhookResponseMode,
    pub response_code: Option<u16>,
    pub response_headers: Option<std::collections::BTreeMap<String, String>>,
    pub whitelist: Option<Vec<String>>,
    pub options: WebhookOptions,
    pub enabled: bool,
    pub comment: Option<Expr>,
}

impl ToSql for DefineWebhookStatement {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        f.push_str("DEFINE WEBHOOK");
        match self.kind {
            DefineKind::Default => {}
            DefineKind::Overwrite => f.push_str(" OVERWRITE"),
            DefineKind::IfNotExists => f.push_str(" IF NOT EXISTS"),
        }
        write_sql!(f, sql_fmt, " {}", CoverStmts(&self.name));
        f.push_str(" ON PATH ");
        self.path.fmt_sql(f, sql_fmt);
        f.push_str(" METHOD ");
        f.push_str(&self.methods.join(", "));
        // AUTH clause
        if !matches!(self.auth, WebhookAuth::None) {
            f.push_str(" AUTH ");
            self.auth.fmt_sql(f, sql_fmt);
            if let Some(ref cred) = self.auth_credential {
                write_sql!(f, sql_fmt, " CREDENTIAL {}", CoverStmts(cred));
            }
        }
        // VERIFY clause
        if !matches!(self.verify, WebhookVerify::None) {
            f.push_str(" VERIFY ");
            self.verify.fmt_sql(f, sql_fmt);
        }
        if let Some(ref secret) = self.secret {
            write_sql!(f, sql_fmt, " SECRET {}", CoverStmts(secret));
        }
        if !matches!(self.content_type, WebhookContentType::Json) {
            f.push_str(" CONTENT TYPE ");
            self.content_type.fmt_sql(f, sql_fmt);
        }
        f.push_str(" HANDLER ");
        self.handler.fmt_sql(f, sql_fmt);
        
        // Extended clauses
        if !matches!(self.respond, WebhookResponseMode::Immediate) {
            f.push_str(" RESPOND ");
            self.respond.fmt_sql(f, sql_fmt);
        }
        if let Some(code) = self.response_code {
            write_sql!(f, sql_fmt, " RESPONSE CODE {}", code);
        }
        if let Some(ref whitelist) = self.whitelist {
            f.push_str(" WHITELIST ");
            f.push_str(&whitelist.join(", "));
        }
        if !matches!(self.options, WebhookOptions { ignore_bots: false, raw_body: false }) {
            f.push_str(" ");
            self.options.fmt_sql(f, sql_fmt);
        }
        
        if !self.enabled {
            f.push_str(" DISABLED");
        }
        if let Some(ref comment) = self.comment {
            write_sql!(f, sql_fmt, " COMMENT {}", CoverStmts(comment));
        }
    }
}

// Conversion from sql:: to expr::
impl From<DefineWebhookStatement> for crate::expr::statements::DefineWebhookStatement {
    fn from(v: DefineWebhookStatement) -> Self {
        crate::expr::statements::DefineWebhookStatement {
            kind: v.kind.into(),
            name: v.name.into(),
            path: v.path.into(),
            methods: v.methods,
            auth: v.auth.into(),
            auth_credential: v.auth_credential.map(|c| c.into()),
            verify: v.verify.into(),
            secret: v.secret.map(|s| s.into()),
            content_type: v.content_type.into(),
            handler: v.handler.into(),
            respond: v.respond.into(),
            response_code: v.response_code,
            response_headers: v.response_headers.map(|h| h.into_iter().collect()),
            whitelist: v.whitelist,
            options: v.options.into(),
            enabled: v.enabled,
            comment: v.comment.map(|c| c.into()),
        }
    }
}

impl From<WebhookAuth> for crate::expr::statements::define::WebhookAuth {
    fn from(v: WebhookAuth) -> Self {
        match v {
            WebhookAuth::None => Self::None,
            WebhookAuth::Basic => Self::Basic,
            WebhookAuth::Bearer => Self::Bearer,
            WebhookAuth::Header(h) => Self::Header(h),
            WebhookAuth::Jwt => Self::Jwt,
        }
    }
}

impl From<WebhookVerify> for crate::expr::statements::define::WebhookVerify {
    fn from(v: WebhookVerify) -> Self {
        match v {
            WebhookVerify::None => Self::None,
            WebhookVerify::Hmac => Self::Hmac,
            WebhookVerify::Stripe => Self::Stripe,
            WebhookVerify::Rsa => Self::Rsa,
            WebhookVerify::Custom(s) => Self::Custom(s),
        }
    }
}

impl From<WebhookContentType> for crate::expr::statements::define::WebhookContentType {
    fn from(v: WebhookContentType) -> Self {
        match v {
            WebhookContentType::Json => Self::Json,
            WebhookContentType::Raw => Self::Raw,
            WebhookContentType::Form => Self::Form,
            WebhookContentType::Binary => Self::Binary,
        }
    }
}

impl From<WebhookResponseMode> for crate::expr::statements::define::WebhookResponseMode {
    fn from(v: WebhookResponseMode) -> Self {
        match v {
            WebhookResponseMode::Immediate => Self::Immediate,
            WebhookResponseMode::Handler => Self::Handler,
            WebhookResponseMode::Streaming => Self::Streaming,
        }
    }
}

impl From<WebhookOptions> for crate::expr::statements::define::WebhookOptions {
    fn from(v: WebhookOptions) -> Self {
        crate::expr::statements::define::WebhookOptions {
            ignore_bots: v.ignore_bots,
            raw_body: v.raw_body,
            binary_property: None,
        }
    }
}

impl From<WebhookHandler> for crate::expr::statements::define::WebhookHandler {
    fn from(v: WebhookHandler) -> Self {
        match v {
            WebhookHandler::Function(e) => Self::Function(e.into()),
            WebhookHandler::Event(e) => Self::Event(e.into()),
        }
    }
}

// Conversion from expr:: to sql::
impl From<crate::expr::statements::DefineWebhookStatement> for DefineWebhookStatement {
    fn from(v: crate::expr::statements::DefineWebhookStatement) -> Self {
        DefineWebhookStatement {
            kind: v.kind.into(),
            name: v.name.into(),
            path: v.path.into(),
            methods: v.methods,
            auth: v.auth.into(),
            auth_credential: v.auth_credential.map(|c| c.into()),
            verify: v.verify.into(),
            secret: v.secret.map(|s| s.into()),
            content_type: v.content_type.into(),
            handler: v.handler.into(),
            respond: v.respond.into(),
            response_code: v.response_code,
            response_headers: v.response_headers.map(|h| h.into_iter().collect()),
            whitelist: v.whitelist,
            options: v.options.into(),
            enabled: v.enabled,
            comment: v.comment.map(|c| c.into()),
        }
    }
}

impl From<crate::expr::statements::define::WebhookAuth> for WebhookAuth {
    fn from(v: crate::expr::statements::define::WebhookAuth) -> Self {
        match v {
            crate::expr::statements::define::WebhookAuth::None => Self::None,
            crate::expr::statements::define::WebhookAuth::Basic => Self::Basic,
            crate::expr::statements::define::WebhookAuth::Bearer => Self::Bearer,
            crate::expr::statements::define::WebhookAuth::Header(h) => Self::Header(h),
            crate::expr::statements::define::WebhookAuth::Jwt => Self::Jwt,
        }
    }
}

impl From<crate::expr::statements::define::WebhookVerify> for WebhookVerify {
    fn from(v: crate::expr::statements::define::WebhookVerify) -> Self {
        match v {
            crate::expr::statements::define::WebhookVerify::None => Self::None,
            crate::expr::statements::define::WebhookVerify::Hmac => Self::Hmac,
            crate::expr::statements::define::WebhookVerify::Stripe => Self::Stripe,
            crate::expr::statements::define::WebhookVerify::Rsa => Self::Rsa,
            crate::expr::statements::define::WebhookVerify::Custom(s) => Self::Custom(s),
        }
    }
}

impl From<crate::expr::statements::define::WebhookContentType> for WebhookContentType {
    fn from(v: crate::expr::statements::define::WebhookContentType) -> Self {
        match v {
            crate::expr::statements::define::WebhookContentType::Json => Self::Json,
            crate::expr::statements::define::WebhookContentType::Raw => Self::Raw,
            crate::expr::statements::define::WebhookContentType::Form => Self::Form,
            crate::expr::statements::define::WebhookContentType::Binary => Self::Binary,
        }
    }
}

impl From<crate::expr::statements::define::WebhookResponseMode> for WebhookResponseMode {
    fn from(v: crate::expr::statements::define::WebhookResponseMode) -> Self {
        match v {
            crate::expr::statements::define::WebhookResponseMode::Immediate => Self::Immediate,
            crate::expr::statements::define::WebhookResponseMode::Handler => Self::Handler,
            crate::expr::statements::define::WebhookResponseMode::Streaming => Self::Streaming,
        }
    }
}

impl From<crate::expr::statements::define::WebhookOptions> for WebhookOptions {
    fn from(v: crate::expr::statements::define::WebhookOptions) -> Self {
        WebhookOptions {
            ignore_bots: v.ignore_bots,
            raw_body: v.raw_body,
        }
    }
}

impl From<crate::expr::statements::define::WebhookHandler> for WebhookHandler {
    fn from(v: crate::expr::statements::define::WebhookHandler) -> Self {
        match v {
            crate::expr::statements::define::WebhookHandler::Function(e) => Self::Function(e.into()),
            crate::expr::statements::define::WebhookHandler::Event(e) => Self::Event(e.into()),
        }
    }
}
