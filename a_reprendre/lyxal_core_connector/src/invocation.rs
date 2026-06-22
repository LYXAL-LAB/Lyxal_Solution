//! Connector invocation logic for outbound HTTP calls.
//!
//! This module is the runtime engine for connectors. It:
//! 1. Resolves the connector + endpoint from the database
//! 2. Builds the HTTP request (URL interpolation, auth, headers, body)
//! 3. Executes the request with retry and rate-limit support
//! 4. Maps errors according to the connector's ON ERROR definitions
//! 5. Returns the response as a Lyxal `Value`

use std::collections::HashMap;
use std::time::Duration;

use anyhow::Result;
use reqwest::Client;
use tracing::{debug, warn};

use crate::lyxal_core_db::catalog::schema::connector::{
    ConnectorAuthDefinition, ConnectorDefinition, ConnectorEndpointDefinition,
};
use crate::lyxal_core_db::catalog::ApiMethod;
use crate::lyxal_core_db::val::Value;

use crate::lyxal_core_connector::err::ConnectorError;
use crate::lyxal_core_connector::request::ConnectorRequest;
use crate::lyxal_core_connector::response::ConnectorResponse;

// =========================================================================
// Path interpolation
// =========================================================================

/// Resolves template variables in a URL path segment.
///
/// Replaces `{key}` placeholders with the corresponding value from `params`.
/// String values are inserted without surrounding quotes.
///
/// # Example
/// ```text
/// "/users/{id}/posts" + { id: "123" } → "/users/123/posts"
/// ```
fn interpolate_path(
    path: &str,
    params: &Value,
    connector_name: &str,
    endpoint_name: &str,
) -> Result<String> {
    let mut result = path.to_string();

    if let Value::Object(obj) = params {
        for (k, v) in obj.iter() {
            let placeholder = format!("{{{}}}", k);
            if result.contains(&placeholder) {
                // Use raw string representation (no surrounding quotes)
                let replacement = match v {
                    Value::String(s) => s.clone(),
                    other => other.to_string(),
                };
                result = result.replace(&placeholder, &replacement);
            }
        }
    }

    // Check for unresolved placeholders
    if let Some(start) = result.find('{') {
        if let Some(end) = result[start..].find('}') {
            let param = &result[start + 1..start + end];
            return Err(ConnectorError::MissingParameter {
                connector: connector_name.to_string(),
                endpoint: endpoint_name.to_string(),
                param: param.to_string(),
            }
            .into());
        }
    }

    Ok(result)
}

// =========================================================================
// Request building
// =========================================================================

/// Builds a `ConnectorRequest` from a connector definition, endpoint name,
/// and user-provided parameters.
///
/// This function:
/// - Finds the matching endpoint by name
/// - Interpolates the path template with params
/// - Merges connector-level headers
/// - Injects authentication (Bearer, Basic, ApiKey)
/// - Sets the body for POST/PUT/PATCH methods
/// - Applies the endpoint-level timeout
fn build_request(
    connector: &ConnectorDefinition,
    endpoint_name: &str,
    params: &Value,
) -> Result<ConnectorRequest> {
    // ── Find the endpoint ──
    let endpoint = connector
        .endpoints()
        .iter()
        .find(|e| e.name == endpoint_name)
        .ok_or_else(|| ConnectorError::EndpointNotFound {
            connector: connector.name().to_string(),
            endpoint: endpoint_name.to_string(),
        })?;

    // ── Build the URL ──
    let path = interpolate_path(
        &endpoint.path,
        params,
        connector.name(),
        endpoint_name,
    )?;
    let url = format!(
        "{}{}",
        connector.base_url().trim_end_matches('/'),
        path
    );

    // ── Headers ──
    let mut headers: HashMap<String, String> = connector
        .headers()
        .iter()
        .map(|(k, v)| (k.clone(), v.clone()))
        .collect();

    // ── Auth injection ──
    if let Some(auth) = connector.auth() {
        match auth {
            ConnectorAuthDefinition::Bearer(token) => {
                headers.insert(
                    "Authorization".to_string(),
                    format!("Bearer {}", token),
                );
            }
            ConnectorAuthDefinition::Basic(user, pass) => {
                use base64::Engine;
                let encoded = base64::engine::general_purpose::STANDARD
                    .encode(format!("{}:{}", user, pass));
                headers.insert(
                    "Authorization".to_string(),
                    format!("Basic {}", encoded),
                );
            }
            ConnectorAuthDefinition::ApiKey {
                name,
                value,
                in_header,
            } => {
                if *in_header {
                    headers.insert(name.clone(), value.clone());
                }
                // ApiKey as query parameter is handled below when building the URL
            }
        }
    }

    // ── ApiKey as query param ──
    let mut url = url;
    if let Some(ConnectorAuthDefinition::ApiKey { name, value, in_header }) = connector.auth() {
        if !in_header {
            let separator = if url.contains('?') { "&" } else { "?" };
            url = format!("{}{}{}", url, separator, format!("{}={}", name, value));
        }
    }

    // ── Body ──
    let body = match endpoint.method {
        ApiMethod::Post | ApiMethod::Put | ApiMethod::Patch => {
            Some(value_to_json(params))
        }
        _ => None,
    };

    // ── Timeout ──
    let timeout_ms = endpoint
        .timeout
        .as_ref()
        .and_then(|t| parse_timeout_ms(t));

    Ok(ConnectorRequest {
        url,
        method: endpoint.method,
        headers,
        body,
        timeout_ms,
    })
}

/// Parses a timeout string (e.g. "5s", "500ms", "30000") into milliseconds.
fn parse_timeout_ms(timeout: &str) -> Option<u64> {
    let trimmed = timeout.trim();
    if let Some(secs) = trimmed.strip_suffix('s') {
        if let Some(ms) = secs.strip_suffix('m') {
            ms.parse::<u64>().ok()
        } else {
            secs.parse::<u64>().ok().map(|s| s * 1000)
        }
    } else {
        trimmed.parse::<u64>().ok()
    }
}

/// Converts a Lyxal `Value` into a `serde_json::Value` for the request body.
fn value_to_json(val: &Value) -> serde_json::Value {
    match val {
        Value::None | Value::Null => serde_json::Value::Null,
        Value::Bool(b) => serde_json::Value::Bool(*b),
        Value::String(s) => serde_json::Value::String(s.clone()),
        Value::Number(n) => {
            // Try to preserve int vs float
            serde_json::Value::Number(
                serde_json::Number::from_f64(n.to_float()).unwrap_or(serde_json::Number::from(0)),
            )
        }
        Value::Object(obj) => {
            let map: serde_json::Map<String, serde_json::Value> = obj
                .iter()
                .map(|(k, v)| (k.clone(), value_to_json(v)))
                .collect();
            serde_json::Value::Object(map)
        }
        Value::Array(arr) => {
            let vec: Vec<serde_json::Value> = arr.iter().map(value_to_json).collect();
            serde_json::Value::Array(vec)
        }
        // Fallback: convert to string
        other => serde_json::Value::String(other.to_string()),
    }
}

/// Converts a `serde_json::Value` into a Lyxal `Value`.
fn json_to_value(json: serde_json::Value) -> Value {
    match json {
        serde_json::Value::Null => Value::Null,
        serde_json::Value::Bool(b) => Value::Bool(b),
        serde_json::Value::Number(n) => {
            if let Some(i) = n.as_i64() {
                Value::from(i)
            } else if let Some(f) = n.as_f64() {
                Value::from(f)
            } else {
                Value::from(n.to_string())
            }
        }
        serde_json::Value::String(s) => Value::from(s),
        serde_json::Value::Array(arr) => {
            Value::from(arr.into_iter().map(json_to_value).collect::<Vec<Value>>())
        }
        serde_json::Value::Object(map) => {
            let btree: std::collections::BTreeMap<String, Value> = map
                .into_iter()
                .map(|(k, v)| (k, json_to_value(v)))
                .collect();
            Value::Object(crate::lyxal_core_db::val::Object(btree))
        }
    }
}

// =========================================================================
// HTTP execution
// =========================================================================

/// Executes a single HTTP request via reqwest.
async fn execute_request(
    client: &Client,
    req: &ConnectorRequest,
) -> Result<ConnectorResponse> {
    let method = match req.method {
        ApiMethod::Get => reqwest::Method::GET,
        ApiMethod::Post => reqwest::Method::POST,
        ApiMethod::Put => reqwest::Method::PUT,
        ApiMethod::Patch => reqwest::Method::PATCH,
        ApiMethod::Delete => reqwest::Method::DELETE,
        ApiMethod::Trace => reqwest::Method::TRACE,
    };

    let mut builder = client.request(method, &req.url);

    // Headers
    for (k, v) in &req.headers {
        builder = builder.header(k, v);
    }

    // Timeout
    if let Some(ms) = req.timeout_ms {
        builder = builder.timeout(Duration::from_millis(ms));
    }

    // Body
    if let Some(body) = &req.body {
        builder = builder.json(body);
    }

    let resp = builder.send().await.map_err(|e| {
        ConnectorError::HttpRequestFailed {
            url: req.url.clone(),
            message: e.to_string(),
        }
    })?;

    let status = resp.status().as_u16();

    let headers: HashMap<String, String> = resp
        .headers()
        .iter()
        .filter_map(|(k, v)| v.to_str().ok().map(|v| (k.to_string(), v.to_string())))
        .collect();

    // Parse response body as JSON, fallback to string, fallback to Null
    let body = match resp.text().await {
        Ok(text) => match serde_json::from_str::<serde_json::Value>(&text) {
            Ok(json) => json_to_value(json),
            Err(_) => Value::from(text),
        },
        Err(_) => Value::Null,
    };

    Ok(ConnectorResponse {
        status,
        headers,
        body,
    })
}

// =========================================================================
// Main entry point
// =========================================================================

/// Processes a `connector::call()` invocation.
///
/// This is the main entry point called by the built-in function
/// `connector::call(connector_name, endpoint_name, params)`.
///
/// # Flow
/// 1. Resolves the endpoint from the connector definition
/// 2. Builds the HTTP request (URL, headers, auth, body)
/// 3. Executes the request with retry logic (exponential backoff)
/// 4. Applies error mappings from `ON ERROR` clauses
/// 5. Returns the response as a Lyxal `Value`
///
/// # Arguments
/// * `connector` — The `ConnectorDefinition` loaded from the KV store
/// * `endpoint_name` — The name of the endpoint to call
/// * `params` — User-provided parameters for path interpolation and body
///
/// # Returns
/// * `Ok(Value)` — The response body (or full response object for errors)
/// * `Err(ConnectorError)` — On failure (timeout, auth, HTTP error, etc.)
pub async fn process_connector_call(
    connector: &ConnectorDefinition,
    endpoint_name: &str,
    params: Value,
) -> Result<Value> {
    let req = build_request(connector, endpoint_name, &params)?;

    // ── Retry configuration ──
    let max_attempts = connector
        .retry()
        .map(|r| r.attempts)
        .unwrap_or(1);

    let backoff_ms = connector
        .retry()
        .map(|r| r.backoff_ms)
        .unwrap_or(0);

    let retry_on: Vec<u16> = connector
        .retry()
        .map(|r| r.on_status.clone())
        .unwrap_or_default();

    // ── Rate limiting ──
    if let Some(rl) = connector.rate_limit() {
        crate::lyxal_core_connector::rate_limit::check_rate_limit(
            connector.name(),
            rl.requests,
            rl.per_ms,
        )?;
    }

    let client = Client::new();
    let mut last_err: Option<anyhow::Error> = None;

    for attempt in 0..max_attempts {
        // ── Backoff delay (skip on first attempt) ──
        if attempt > 0 && backoff_ms > 0 {
            let delay = backoff_ms * (1u64 << attempt.saturating_sub(1)); // exponential
            debug!(
                connector = %connector.name(),
                endpoint = %endpoint_name,
                attempt = attempt + 1,
                delay_ms = delay,
                "Retrying connector call after backoff"
            );
            tokio::time::sleep(Duration::from_millis(delay)).await;
        }

        let response = execute_request(&client, &req).await;

        match response {
            Ok(resp) => {
                // ── Error mapping (ON ERROR clauses) ──
                if let Some(mapped) = connector
                    .error_map()
                    .iter()
                    .find(|e| e.status == resp.status)
                {
                    return Err(ConnectorError::MappedError {
                        connector: connector.name().to_string(),
                        message: mapped.message.clone(),
                        code: mapped.code.clone(),
                    }
                    .into());
                }

                // ── Retry on specific status codes ──
                if retry_on.contains(&resp.status) && attempt < max_attempts - 1 {
                    warn!(
                        connector = %connector.name(),
                        endpoint = %endpoint_name,
                        status = resp.status,
                        attempt = attempt + 1,
                        max = max_attempts,
                        "Retryable status code received"
                    );
                    last_err = Some(
                        ConnectorError::HttpResponseError {
                            connector: connector.name().to_string(),
                            status: resp.status,
                            message: format!("HTTP {} — will retry", resp.status),
                        }
                        .into(),
                    );
                    continue;
                }

                // ── Non-retryable error status ──
                if resp.status >= 400 {
                    return Err(ConnectorError::HttpResponseError {
                        connector: connector.name().to_string(),
                        status: resp.status,
                        message: resp.body.to_string(),
                    }
                    .into());
                }

                // ── Success ──
                return Ok(resp.into_value());
            }
            Err(e) => {
                warn!(
                    connector = %connector.name(),
                    endpoint = %endpoint_name,
                    attempt = attempt + 1,
                    error = %e,
                    "Connector request failed"
                );
                last_err = Some(e);

                if attempt >= max_attempts - 1 {
                    break;
                }
                continue;
            }
        }
    }

    // ── All retries exhausted ──
    if max_attempts > 1 {
        Err(ConnectorError::RetriesExhausted {
            connector: connector.name().to_string(),
            attempts: max_attempts,
        }
        .into())
    } else {
        Err(last_err.unwrap_or_else(|| {
            ConnectorError::Internal("Connector call failed with no error details".to_string())
                .into()
        }))
    }
}
