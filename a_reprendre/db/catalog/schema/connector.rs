use std::fmt::{self, Display};

use lyxal_revision::revisioned;
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::catalog::ApiMethod;
use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_kvs::impl_kv_value_revisioned;
use crate::lyxal_core_db::sql;
use crate::lyxal_core_db::val::{Object, Value};
use crate::map;

/// The Connector definition.
#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
#[non_exhaustive]
pub struct ConnectorDefinition {
    /// The name of the connector.
    pub(crate) name: String,
    /// The base URL of the connector.
    pub(crate) base_url: String,
    /// The default headers of the connector.
    pub(crate) headers: Vec<(String, String)>,
    /// The auth configuration.
    pub(crate) auth: Option<ConnectorAuthDefinition>,
    /// The endpoints of the connector.
    pub(crate) endpoints: Vec<ConnectorEndpointDefinition>,
    /// The retry configuration.
    pub(crate) retry: Option<ConnectorRetryDefinition>,
    /// The rate limit configuration.
    pub(crate) rate_limit: Option<ConnectorRateLimitDefinition>,
    /// The error mappings.
    pub(crate) error_map: Vec<ConnectorErrorDefinition>,
    /// An optional comment.
    pub(crate) comment: Option<String>,
}

impl_kv_value_revisioned!(ConnectorDefinition);

impl ConnectorDefinition {
    fn to_sql_definition(&self) -> sql::statements::DefineConnectorStatement {
        sql::statements::DefineConnectorStatement {
            kind: sql::statements::define::DefineKind::Default,
            name: self.name.clone(),
            base_url: sql::Expr::Literal(sql::Literal::String(self.base_url.clone())),
            headers: if self.headers.is_empty() {
                None
            } else {
                Some(sql::Expr::Literal(sql::Literal::Object(
                    self.headers.iter()
                        .map(|(k, v)| (k.clone(), sql::Expr::Literal(sql::Literal::String(v.clone()))))
                        .collect()
                )))
            },
            auth: self.auth.as_ref().map(|a| a.to_sql_auth()),
            endpoints: self.endpoints.iter().map(|e| e.to_sql_endpoint()).collect(),
            config: sql::statements::define::connector::ConnectorConfig {
                retry: self.retry.as_ref().map(|r| r.to_sql_retry()),
                rate_limit: self.rate_limit.as_ref().map(|l| l.to_sql_rate_limit()),
            },
            error_map: self.error_map.iter().map(|e| e.to_sql_error()).collect(),
            comment: self.comment.clone()
                .map(|c| sql::Expr::Literal(sql::Literal::String(c))),
        }
    }

    // ── Public accessors ──

    /// Returns the name of this connector.
    pub fn name(&self) -> &str {
        &self.name
    }

    /// Returns the base URL of this connector.
    pub fn base_url(&self) -> &str {
        &self.base_url
    }

    /// Returns the default headers for this connector.
    pub fn headers(&self) -> &[(String, String)] {
        &self.headers
    }

    /// Returns the auth configuration, if any.
    pub fn auth(&self) -> Option<&ConnectorAuthDefinition> {
        self.auth.as_ref()
    }

    /// Returns the list of endpoint definitions.
    pub fn endpoints(&self) -> &[ConnectorEndpointDefinition] {
        &self.endpoints
    }

    /// Returns the retry configuration, if any.
    pub fn retry(&self) -> Option<&ConnectorRetryDefinition> {
        self.retry.as_ref()
    }

    /// Returns the rate limit configuration, if any.
    pub fn rate_limit(&self) -> Option<&ConnectorRateLimitDefinition> {
        self.rate_limit.as_ref()
    }

    /// Returns the error mappings.
    pub fn error_map(&self) -> &[ConnectorErrorDefinition] {
        &self.error_map
    }

    /// Returns the optional comment.
    pub fn comment(&self) -> Option<&str> {
        self.comment.as_deref()
    }
}


impl ToSql for ConnectorDefinition {
    fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
        self.to_sql_definition().fmt_sql(f, fmt)
    }
}

impl InfoStructure for ConnectorDefinition {
    fn structure(self) -> Value {
        Value::from(Object(map! {
            "name".to_string() => self.name.into(),
            "base_url".to_string() => self.base_url.into(),
            "endpoints".to_string() => Value::from(
                self.endpoints.into_iter()
                    .map(InfoStructure::structure)
                    .collect::<Vec<Value>>()
            ),
            "comment".to_string(), if let Some(comment) = self.comment => comment.into(),
        }))
    }
}

/// Connector endpoint definition.
#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct ConnectorEndpointDefinition {
    pub name: String,
    pub method: ApiMethod,
    pub path: String,
    pub timeout: Option<String>,
}

impl_kv_value_revisioned!(ConnectorEndpointDefinition);

impl ConnectorEndpointDefinition {
    fn to_sql_endpoint(&self) -> sql::statements::define::connector::ConnectorEndpoint {
        sql::statements::define::connector::ConnectorEndpoint {
            name: self.name.clone(),
            method: self.method,
            path: sql::Expr::Literal(sql::Literal::String(self.path.clone())),
            query: None,
            body: None,
            timeout: self.timeout.as_ref().map(|t| {
                sql::Expr::Literal(sql::Literal::String(t.clone()))
            }),
        }
    }
}

impl InfoStructure for ConnectorEndpointDefinition {
    fn structure(self) -> Value {
        Value::from(Object(map! {
            "name".to_string() => self.name.into(),
            "method".to_string() => self.method.to_string().into(),
            "path".to_string() => self.path.into(),
        }))
    }
}

/// Connector auth definition.
#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub enum ConnectorAuthDefinition {
    Bearer(String),
    Basic(String, String),
    ApiKey { name: String, value: String, in_header: bool },
}

impl_kv_value_revisioned!(ConnectorAuthDefinition);

impl ConnectorAuthDefinition {
    fn to_sql_auth(&self) -> sql::statements::define::connector::ConnectorAuth {
        use sql::statements::define::connector::{ConnectorAuth, AuthLocation};
        match self {
            Self::Bearer(t) => ConnectorAuth::Bearer(
                sql::Expr::Literal(sql::Literal::String(t.clone()))
            ),
            Self::Basic(u, p) => ConnectorAuth::Basic(
                sql::Expr::Literal(sql::Literal::String(u.clone())),
                sql::Expr::Literal(sql::Literal::String(p.clone())),
            ),
            Self::ApiKey { name, value, in_header } => ConnectorAuth::ApiKey {
                name: sql::Expr::Literal(sql::Literal::String(name.clone())),
                value: sql::Expr::Literal(sql::Literal::String(value.clone())),
                location: if *in_header { AuthLocation::Header } else { AuthLocation::Query },
            },
        }
    }
}

/// Connector retry definition.
#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct ConnectorRetryDefinition {
    pub attempts: u8,
    pub backoff_ms: u64,
    pub on_status: Vec<u16>,
}

impl_kv_value_revisioned!(ConnectorRetryDefinition);

impl ConnectorRetryDefinition {
    fn to_sql_retry(&self) -> sql::statements::define::connector::RetryConfig {
        sql::statements::define::connector::RetryConfig {
            attempts: sql::Expr::Literal(sql::Literal::Integer(self.attempts as i64)),
            backoff: sql::Expr::Literal(sql::Literal::Integer(self.backoff_ms as i64)),
            on: self.on_status.iter()
                .map(|s| sql::Expr::Literal(sql::Literal::Integer(*s as i64)))
                .collect(),
        }
    }
}

/// Connector rate limit definition.
#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct ConnectorRateLimitDefinition {
    pub requests: u32,
    pub per_ms: u64,
}

impl_kv_value_revisioned!(ConnectorRateLimitDefinition);

impl ConnectorRateLimitDefinition {
    fn to_sql_rate_limit(&self) -> sql::statements::define::connector::RateLimitConfig {
        sql::statements::define::connector::RateLimitConfig {
            requests: sql::Expr::Literal(sql::Literal::Integer(self.requests as i64)),
            per: sql::Expr::Literal(sql::Literal::Integer(self.per_ms as i64)),
        }
    }
}

/// Connector error mapping definition.
#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct ConnectorErrorDefinition {
    pub status: u16,
    pub message: String,
    pub code: Option<String>,
}

impl_kv_value_revisioned!(ConnectorErrorDefinition);

impl ConnectorErrorDefinition {
    fn to_sql_error(&self) -> sql::statements::define::connector::ConnectorErrorMap {
        sql::statements::define::connector::ConnectorErrorMap {
            status: sql::Expr::Literal(sql::Literal::Integer(self.status as i64)),
            message: sql::Expr::Literal(sql::Literal::String(self.message.clone())),
            code: self.code.as_ref().map(|c| {
                sql::Expr::Literal(sql::Literal::String(c.clone()))
            }),
        }
    }
}