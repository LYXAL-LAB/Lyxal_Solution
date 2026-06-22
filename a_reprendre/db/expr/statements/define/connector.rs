use anyhow::{Result, bail};
use reblessive::tree::Stk;
use lyxal_types_core::{SqlFormat, ToSql};

use super::{CursorDoc, DefineKind};
use crate::lyxal_core_db::catalog::{ApiMethod, ConnectorDefinition, ConnectorEndpointDefinition, ConnectorErrorDefinition, ConnectorRetryDefinition, ConnectorRateLimitDefinition};
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::{Base, Expr, FlowResultExt as _, Value};
use crate::lyxal_core_db::iam::{Action, ResourceKind};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefineConnectorStatement {
    pub kind: DefineKind,
    pub name: String,
    pub url: Expr,
    pub headers: Option<Expr>,
    pub auth: Option<ConnectorAuth>,
    pub endpoints: Vec<ConnectorEndpoint>,
    pub config: ConnectorConfig,
    pub error_map: Vec<ConnectorErrorMap>,
    pub comment: Option<Expr>,
}

impl DefineConnectorStatement {
    #[instrument(level = "trace", name = "DefineConnectorStatement::compute", skip_all)]
    pub(crate) async fn compute(
        &self,
        stk: &mut Stk,
        ctx: &FrozenContext,
        opt: &Options,
        doc: Option<&CursorDoc>,
    ) -> Result<Value> {
        // Allowed to run?
        opt.is_allowed(Action::Edit, ResourceKind::Connector, &Base::Db)?;
        
        // Fetch the transaction
        let txn = ctx.tx();
        let (ns, db) = ctx.get_ns_db_ids(opt).await?;
        
        // Check if the definition exists
        if txn.get_db_connector(ns, db, &self.name.to_string()).await?.is_some() {
            match self.kind {
                DefineKind::Default => {
                    if !opt.import {
                        bail!(Error::ConnectorAlreadyExists {
                            value: self.name.to_string(),
                        });
                    }
                }
                DefineKind::Overwrite => {}
                DefineKind::IfNotExists => {
                    return Ok(Value::None);
                }
            }
        }

        let url = stk.run(|stk| self.url.compute(stk, ctx, opt, doc)).await.catch_return()?;
        let url: String = url.coerce_to::<String>()?;

        let headers = if let Some(ref h) = self.headers {
            Some(stk.run(|stk| h.compute(stk, ctx, opt, doc)).await.catch_return()?)
        } else {
            None
        };

        let mut endpoints = Vec::new();
        for ep in self.endpoints.iter() {
            endpoints.push(ConnectorEndpointDefinition {
                name: ep.name.clone(),
                method: ep.method.clone(),
                path: ep.path.clone(),
                query: ep.query.clone(),
                body: ep.body.clone(),
                timeout: ep.timeout.clone(),
            });
        }

        let mut error_map = Vec::new();
        for err in self.error_map.iter() {
            error_map.push(ConnectorErrorDefinition {
                status: err.status.clone(),
                message: err.message.clone(),
                code: err.code.clone(),
            });
        }

        let comment = if let Some(ref c) = self.comment {
            Some(stk.run(|stk| c.compute(stk, ctx, opt, doc)).await.catch_return()?.coerce_to::<String>()?)
        } else {
            None
        };

        let def = ConnectorDefinition {
            name: self.name.to_string(),
            url,
            headers,
            auth: self.auth.clone().map(Into::into),
            endpoints,
            retry: self.config.retry.as_ref().map(|r| ConnectorRetryDefinition {
                attempts: r.attempts.clone(),
                backoff: r.backoff.clone(),
                on: r.on.clone(),
            }),
            rate_limit: self.config.rate_limit.as_ref().map(|l| ConnectorRateLimitDefinition {
                requests: l.requests.clone(),
                per: l.per.clone(),
            }),
            error_map,
            comment,
        };

        txn.put_db_connector(ns, db, &def).await?;
        txn.clear_cache();
        
        Ok(Value::None)
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct ConnectorEndpoint {
    pub name: String,
    pub method: ApiMethod,
    pub path: Expr,
    pub query: Option<Expr>,
    pub body: Option<Expr>,
    pub timeout: Option<Expr>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub(crate) struct ConnectorConfig {
    pub retry: Option<RetryConfig>,
    pub rate_limit: Option<RateLimitConfig>,
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RetryConfig {
    pub attempts: Expr,
    pub backoff: Expr,
    pub on: Vec<Expr>,
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RateLimitConfig {
    pub requests: Expr,
    pub per: Expr,
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) enum ConnectorAuth {
    Bearer(Expr),
    Basic(Expr, Expr),
    ApiKey { name: Expr, value: Expr, location: AuthLocation },
}

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub enum AuthLocation { Header, Query }

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct ConnectorErrorMap {
    pub status: Expr,
    pub message: Expr,
    pub code: Option<Expr>,
}
