use crate::lyxal_core_db::sql::statements::define::DefineKind;
// Ident removed - use inline string
use crate::lyxal_core_db::sql::{CoverStmts, Expr};
use crate::lyxal_core_db::val::Value;
use crate::lyxal_core_db::sql::Literal;
use crate::lyxal_core_utils::fmt::Fmt;
use lyxal_types_core::{SqlFormat, ToSql, write_sql};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct DefineConnectorStatement {
    pub kind: DefineKind,
    pub name: String,
    pub base_url: Expr,
    pub headers: Option<Expr>,
    pub auth: Option<ConnectorAuth>,
    pub endpoints: Vec<ConnectorEndpoint>,
    pub config: ConnectorConfig,
    pub error_map: Vec<ConnectorErrorMap>,
    pub comment: Option<Expr>,
}

impl Default for DefineConnectorStatement {
    fn default() -> Self {
        Self {
            kind: DefineKind::Default,
            name: String::new(),
            base_url: Expr::Literal(Literal::None),
            headers: None,
            auth: None,
            endpoints: Vec::new(),
            config: ConnectorConfig::default(),
            error_map: Vec::new(),
            comment: None,
        }
    }
}

impl ToSql for DefineConnectorStatement {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        write_sql!(f, sql_fmt, "DEFINE CONNECTOR");
        match self.kind {
            DefineKind::Default => {}
            DefineKind::Overwrite => write_sql!(f, sql_fmt, " OVERWRITE"),
            DefineKind::IfNotExists => write_sql!(f, sql_fmt, " IF NOT EXISTS"),
        }
        write_sql!(f, sql_fmt, " {} URL {}", self.name, CoverStmts(&self.base_url));
        
        let sql_fmt = sql_fmt.increment();
        
        if let Some(headers) = &self.headers {
            write_sql!(f, sql_fmt, " HEADERS {}", CoverStmts(headers));
        }

        if let Some(auth) = &self.auth {
            write_sql!(f, sql_fmt, " AUTH {}", auth);
        }

        write_sql!(f, sql_fmt, "{}", self.config);

        for endpoint in &self.endpoints {
            write_sql!(f, sql_fmt, " ENDPOINT {}", endpoint);
        }

        for error in &self.error_map {
            write_sql!(f, sql_fmt, " ON ERROR {}", error);
        }

        if let Some(comment) = &self.comment {
            write_sql!(f, sql_fmt, " COMMENT {}", CoverStmts(comment));
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ConnectorEndpoint {
    pub name: String,
    pub method: crate::lyxal_core_db::catalog::ApiMethod,
    pub path: Expr,
    pub query: Option<Expr>,
    pub body: Option<Expr>,
    pub timeout: Option<Expr>,
}

impl ToSql for ConnectorEndpoint {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        write_sql!(f, sql_fmt, " {} {} PATH {}", self.name, self.method, CoverStmts(&self.path));
        if let Some(query) = &self.query {
            write_sql!(f, sql_fmt, " QUERY {}", CoverStmts(query));
        }
        if let Some(body) = &self.body {
            write_sql!(f, sql_fmt, " BODY {}", CoverStmts(body));
        }
        if let Some(timeout) = &self.timeout {
            write_sql!(f, sql_fmt, " TIMEOUT {}", CoverStmts(timeout));
        }
    }
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Serialize, Deserialize)]
pub struct ConnectorConfig {
    pub retry: Option<RetryConfig>,
    pub rate_limit: Option<RateLimitConfig>,
}

impl ToSql for ConnectorConfig {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        if let Some(retry) = &self.retry {
            write_sql!(f, sql_fmt, " RETRY {} BACKOFF {}", 
                CoverStmts(&retry.attempts), CoverStmts(&retry.backoff));
            
            if !retry.on.is_empty() {
                write_sql!(f, sql_fmt, " ON ");
                for (i, code) in retry.on.iter().enumerate() {
                    if i > 0 { write_sql!(f, sql_fmt, ", "); }
                    write_sql!(f, sql_fmt, "{}", CoverStmts(code));
                }
            }
        }
        if let Some(limit) = &self.rate_limit {
            write_sql!(f, sql_fmt, " LIMIT {} PER {}", 
                CoverStmts(&limit.requests), CoverStmts(&limit.per));
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RetryConfig {
    pub attempts: Expr,
    pub backoff: Expr,
    pub on: Vec<Expr>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RateLimitConfig {
    pub requests: Expr,
    pub per: Expr,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum ConnectorAuth {
    Bearer(Expr),
    Basic(Expr, Expr),
    ApiKey { name: Expr, value: Expr, location: AuthLocation },
}

impl ToSql for ConnectorAuth {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        match self {
            Self::Bearer(t) => write_sql!(f, sql_fmt, "BEARER {}", CoverStmts(t)),
            Self::Basic(u, p) => write_sql!(f, sql_fmt, "BASIC {} {}", CoverStmts(u), CoverStmts(p)),
            Self::ApiKey { name, value, location } => 
                write_sql!(f, sql_fmt, "APIKEY {} VALUE {} IN {}", 
                    CoverStmts(name), CoverStmts(value), location),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum AuthLocation { Header, Query }

impl ToSql for AuthLocation {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        match self {
            Self::Header => write_sql!(f, sql_fmt, "HEADER"),
            Self::Query  => write_sql!(f, sql_fmt, "QUERY"),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ConnectorErrorMap {
    pub status: Expr,
    pub message: Expr,
    pub code: Option<Expr>,
}

impl ToSql for ConnectorErrorMap {
    fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
        write_sql!(f, sql_fmt, " STATUS {} MESSAGE {}", 
            CoverStmts(&self.status), CoverStmts(&self.message));
        if let Some(code) = &self.code {
            write_sql!(f, sql_fmt, " CODE {}", CoverStmts(code));
        }
    }
}
