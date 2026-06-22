//! Connector functions for invoking defined connector endpoints from Lyxal_QL.
//!
//! This module bridges the built-in connector functions
//! to the `lyxal_apps_connector` runtime engine.

use anyhow::Result;
use reblessive::tree::Stk;
use tracing::trace;

use super::args::Optional;
use crate::lyxal_core_db::catalog::providers::ConnectorProvider;
use crate::lyxal_core_db::catalog::schema::connector::ConnectorDefinition;
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_db::val::{Object, Value};

// =========================================================================
// connector::call — Invoke a connector endpoint
// =========================================================================

/// Invokes a connector endpoint programmatically from within Lyxal_QL.
///
/// # Example
/// ```surql
/// connector::call("github", "get_user", { id: "octocat" });
/// ```
pub async fn call(
    (stk, ctx, opt): (&mut Stk, &FrozenContext, &Options),
    (connector_name, endpoint_name, Optional(params)): (String, String, Optional<Value>),
) -> Result<Value> {
    trace!(
        connector = %connector_name,
        endpoint = %endpoint_name,
        "fnc::connector::call invoked"
    );

    let params = params.unwrap_or(Value::None);
    let connector = load_connector(ctx, opt, &connector_name).await?;

    crate::lyxal_core_connector::process_connector_call(&connector, &endpoint_name, params).await
}

// =========================================================================
// connector::list — List all defined connectors
// =========================================================================

/// Lists all connectors defined in the current database.
///
/// Returns an array of objects, each containing the connector name
/// and its base URL.
///
/// # Example
/// ```surql
/// connector::list();
/// -- Returns: [{ name: "github", base_url: "https://api.github.com" }, ...]
/// ```
pub async fn list(
    (_stk, ctx, opt): (&mut Stk, &FrozenContext, &Options),
    _args: (),
) -> Result<Value> {
    trace!("fnc::connector::list invoked");

    let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
    let connectors = ctx.tx().all_db_connectors(ns, db).await?;

    let result: Vec<Value> = connectors
        .iter()
        .map(|cn| {
            let mut map = std::collections::BTreeMap::new();
            map.insert("name".to_string(), Value::from(cn.name().to_string()));
            map.insert("base_url".to_string(), Value::from(cn.base_url().to_string()));
            Value::Object(Object(map))
        })
        .collect();

    Ok(Value::from(result))
}

// =========================================================================
// connector::info — Get info about a specific connector
// =========================================================================

/// Returns detailed information about a specific connector definition.
///
/// The returned object includes the connector name, base URL,
/// endpoints, auth type, retry config, rate limit config, and comment.
///
/// # Example
/// ```surql
/// connector::info("github");
/// -- Returns: { name: "github", base_url: "...", endpoints: [...], ... }
/// ```
pub async fn info(
    (_stk, ctx, opt): (&mut Stk, &FrozenContext, &Options),
    (connector_name,): (String,),
) -> Result<Value> {
    trace!(connector = %connector_name, "fnc::connector::info invoked");

    let connector = load_connector(ctx, opt, &connector_name).await?;

    // Use the InfoStructure trait to build a structured Value
    let base = connector.as_ref().clone().structure();

    // Enrich with additional runtime-relevant info
    let mut map = if let Value::Object(obj) = base {
        obj.0
    } else {
        std::collections::BTreeMap::new()
    };

    // Auth type summary
    let auth_type = connector.auth().map(|a| match a {
        crate::lyxal_core_db::catalog::schema::connector::ConnectorAuthDefinition::Bearer(_) => "bearer",
        crate::lyxal_core_db::catalog::schema::connector::ConnectorAuthDefinition::Basic(_, _) => "basic",
        crate::lyxal_core_db::catalog::schema::connector::ConnectorAuthDefinition::ApiKey { .. } => "apikey",
    });
    if let Some(auth) = auth_type {
        map.insert("auth_type".to_string(), Value::from(auth.to_string()));
    }

    // Retry config summary
    if let Some(retry) = connector.retry() {
        let mut retry_map = std::collections::BTreeMap::new();
        retry_map.insert("attempts".to_string(), Value::from(retry.attempts as i64));
        retry_map.insert("backoff_ms".to_string(), Value::from(retry.backoff_ms as i64));
        map.insert("retry".to_string(), Value::Object(Object(retry_map)));
    }

    // Rate limit config summary
    if let Some(rl) = connector.rate_limit() {
        let mut rl_map = std::collections::BTreeMap::new();
        rl_map.insert("requests".to_string(), Value::from(rl.requests as i64));
        rl_map.insert("per_ms".to_string(), Value::from(rl.per_ms as i64));
        map.insert("rate_limit".to_string(), Value::Object(Object(rl_map)));
    }

    // Endpoint count
    map.insert(
        "endpoint_count".to_string(),
        Value::from(connector.endpoints().len() as i64),
    );

    Ok(Value::Object(Object(map)))
}

// =========================================================================
// connector::health — Ping a connector's base URL
// =========================================================================

/// Checks if a connector's base URL is reachable.
///
/// Sends an HTTP HEAD request to the connector's base URL.
/// Returns an object with `reachable: true/false`, `status`, and `latency_ms`.
///
/// # Example
/// ```surql
/// connector::health("github");
/// -- Returns: { reachable: true, status: 200, latency_ms: 42 }
/// ```
pub async fn health(
    (_stk, ctx, opt): (&mut Stk, &FrozenContext, &Options),
    (connector_name,): (String,),
) -> Result<Value> {
    trace!(connector = %connector_name, "fnc::connector::health invoked");

    let connector = load_connector(ctx, opt, &connector_name).await?;
    let base_url = connector.base_url().to_string();

    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(10))
        .build()?;

    let start = std::time::Instant::now();
    let result = client.head(&base_url).send().await;
    let latency_ms = start.elapsed().as_millis() as i64;

    let mut map = std::collections::BTreeMap::new();
    map.insert("connector".to_string(), Value::from(connector_name));
    map.insert("base_url".to_string(), Value::from(base_url));

    match result {
        Ok(resp) => {
            map.insert("reachable".to_string(), Value::Bool(true));
            map.insert("status".to_string(), Value::from(resp.status().as_u16() as i64));
            map.insert("latency_ms".to_string(), Value::from(latency_ms));
        }
        Err(e) => {
            map.insert("reachable".to_string(), Value::Bool(false));
            map.insert("error".to_string(), Value::from(e.to_string()));
            map.insert("latency_ms".to_string(), Value::from(latency_ms));
        }
    }

    Ok(Value::Object(Object(map)))
}

// =========================================================================
// connector::batch — Call an endpoint for each item in an array
// =========================================================================

/// Calls a connector endpoint for each set of parameters in an array.
///
/// Returns an array of responses, one per input. Failed calls return
/// an error object instead of failing the entire batch.
///
/// # Example
/// ```surql
/// connector::batch("github", "get_user", [
///     { id: "octocat" },
///     { id: "torvalds" }
/// ]);
/// -- Returns: [{ status: 200, body: ... }, { status: 200, body: ... }]
/// ```
pub async fn batch(
    (_stk, ctx, opt): (&mut Stk, &FrozenContext, &Options),
    (connector_name, endpoint_name, params_array): (String, String, Vec<Value>),
) -> Result<Value> {
    trace!(
        connector = %connector_name,
        endpoint = %endpoint_name,
        count = params_array.len(),
        "fnc::connector::batch invoked"
    );

    let connector = load_connector(ctx, opt, &connector_name).await?;

    let mut results = Vec::with_capacity(params_array.len());

    for params in params_array {
        let result = crate::lyxal_core_connector::process_connector_call(
            &connector,
            &endpoint_name,
            params,
        )
        .await;

        match result {
            Ok(value) => results.push(value),
            Err(e) => {
                // Return error as an object instead of failing the entire batch
                let mut err_map = std::collections::BTreeMap::new();
                err_map.insert("error".to_string(), Value::from(true));
                err_map.insert("message".to_string(), Value::from(e.to_string()));
                results.push(Value::Object(Object(err_map)));
            }
        }
    }

    Ok(Value::from(results))
}

// =========================================================================
// Helpers
// =========================================================================

/// Loads a `ConnectorDefinition` from the KV store by name.
async fn load_connector(
    ctx: &FrozenContext,
    opt: &Options,
    name: &str,
) -> Result<std::sync::Arc<ConnectorDefinition>> {
    let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
    ctx.tx()
        .get_db_connector(ns, db, name)
        .await?
        .ok_or_else(|| {
            anyhow::Error::from(Error::ConnectorError(
                crate::lyxal_core_error::ConnectorError::ConnectorNotFound {
                    name: name.to_string(),
                },
            ))
        })
}
