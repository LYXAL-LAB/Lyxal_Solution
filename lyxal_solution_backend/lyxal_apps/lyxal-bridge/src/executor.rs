//! Exécution HTTP avec résilience et traçabilité complète.
//!
//! Ce module contient le **point d'entrée principal** `bridge_call()` et
//! toute la logique d'exécution : envoi HTTP, retry avec backoff exponentiel,
//! error mapping via `bridge_errors`, circuit breaker.
//!
//! **Chaque appel génère un `BridgeTrace`** capturant toutes les phases.
//!
//! ## Flux d'exécution
//!
//! ```text
//! bridge_call()
//!   ├── 1. resolve_operation()     → lit la DB (avec cache)
//!   ├── 2. resolve_auth()          → déchiffre les credentials
//!   ├── 3. build_request()         → construit la requête HTTP
//!   ├── 4. apply_pre_hooks()       → hooks pré-requête (HMAC, etc.)
//!   ├── 5. execute_with_resilience → retry, rate limit, circuit breaker
//!   ├── 6. apply_post_hooks()      → hooks post-réponse (pagination, etc.)
//!   └── 7. return response + trace
//! ```

use std::time::{Duration, Instant};

use reqwest::Method;
use tracing::{debug, warn};

use crate::context::BridgeContext;
use crate::error::BridgeError;
use crate::models::BridgeErrorRule;
use crate::request::{self, BridgeRequest};
use crate::response::{self, BridgeResponse};
use crate::trace::{BridgeTrace, TraceBuilder};

// =========================================================================
// Résultat d'un appel Bridge (valeur + trace)
// =========================================================================

/// Résultat d'un appel Bridge contenant la valeur ET la trace complète.
#[derive(Debug)]
pub struct BridgeCallResult {
    /// Le résultat JSON de l'appel (body de la réponse ou réponse complète)
    pub value: serde_json::Value,
    /// La trace complète de l'exécution
    pub trace: BridgeTrace,
}

// =========================================================================
// Point d'entrée principal
// =========================================================================

/// Point d'entrée principal du Lyxal Bridge.
///
/// Exécute un appel API sortant de manière entièrement dynamique,
/// piloté par les métadonnées des tables `bridge_*`.
///
/// Retourne un `BridgeCallResult` contenant la valeur ET la trace.
pub async fn bridge_call<F, Fut>(
    ctx: &BridgeContext,
    db_query: F,
    provider_name: &str,
    operation_name: &str,
    params: serde_json::Value,
) -> Result<BridgeCallResult, BridgeError>
where
    F: Fn(&str, Vec<(&str, serde_json::Value)>) -> Fut + Clone,
    Fut: std::future::Future<Output = Result<serde_json::Value, BridgeError>>,
{
    // ── Initialiser la trace ──
    let mut trace = TraceBuilder::new(provider_name, operation_name);

    // ── 0. Circuit breaker check ──
    if !ctx.is_provider_allowed(provider_name) {
        let err = BridgeError::CircuitBreakerOpen {
            provider: provider_name.to_string(),
        };
        trace.record_error("circuit_breaker", "CircuitBreakerOpen", &err.to_string(), None);
        let finished = trace.finish_bridge_error(&err);
        tracing::warn!("{}", finished.summary());
        return Err(err);
    }

    // ── 1. Résoudre provider + opération ──
    trace.start_phase("resolve_metadata");
    let resolve_start = Instant::now();
    let (provider, operation, error_rules) =
        match crate::resolver::resolve_operation(ctx, db_query.clone(), provider_name, operation_name).await {
            Ok(result) => {
                let resolve_us = resolve_start.elapsed().as_micros() as u64;
                trace.set_resolve_duration(resolve_us);
                trace.set_cache_hit(ctx.cache_get(provider_name, operation_name).is_some());
                trace.end_phase(Some(&format!(
                    "provider={}, operation={}, error_rules={}",
                    provider_name, operation_name,
                    result.2.len()
                )));
                result
            }
            Err(e) => {
                trace.fail_phase(&e.to_string());
                trace.record_error("resolve_metadata", "ResolutionFailed", &e.to_string(), None);
                let finished = trace.finish_bridge_error(&e);
                tracing::warn!("{}", finished.summary());
                return Err(e);
            }
        };

    // ── 2. Résoudre l'auth ──
    trace.start_phase("resolve_auth");
    let auth = match crate::resolver::resolve_auth(db_query, &provider).await {
        Ok(auth) => {
            let has_auth = auth.is_some();
            trace.end_phase(Some(if has_auth { "auth_resolved" } else { "no_auth" }));
            auth
        }
        Err(e) => {
            trace.fail_phase(&e.to_string());
            trace.record_error("resolve_auth", "AuthFailed", &e.to_string(), None);
            let finished = trace.finish_bridge_error(&e);
            tracing::warn!("{}", finished.summary());
            return Err(e);
        }
    };

    // ── 3. Construire la requête HTTP ──
    trace.start_phase("build_request");
    let build_start = Instant::now();
    let mut bridge_request = match request::build_request(&provider, &operation, &auth, &params) {
        Ok(req) => {
            let build_us = build_start.elapsed().as_micros() as u64;
            trace.set_request_build_duration(build_us);
            trace.set_request(&req.method, &req.url, &req.headers, &req.body);
            trace.end_phase(Some(&format!("{} {}", req.method, req.url)));
            req
        }
        Err(e) => {
            trace.fail_phase(&e.to_string());
            trace.record_error("build_request", "BuildFailed", &e.to_string(), None);
            let finished = trace.finish_bridge_error(&e);
            tracing::warn!("{}", finished.summary());
            return Err(e);
        }
    };

    // ── 4. Appliquer les hooks pré-requête ──
    let hooks = &operation.configuration.hooks;
    if !hooks.is_empty() {
        trace.start_phase("pre_hooks");
        if let Err(e) = ctx.hooks.apply_pre_hooks(hooks, &mut bridge_request) {
            trace.fail_phase(&e.to_string());
            trace.record_error("pre_hooks", "HookFailed", &e.to_string(), None);
            let finished = trace.finish_bridge_error(&e);
            tracing::warn!("{}", finished.summary());
            return Err(e);
        }
        trace.end_phase(Some(&format!("hooks=[{}]", hooks.join(", "))));
    }

    // ── 5. Exécuter avec résilience ──
    trace.start_phase("http_execute");
    let mut bridge_response = match execute_with_resilience(
        ctx, &bridge_request, &error_rules, provider_name, operation_name, &mut trace,
    ).await {
        Ok(resp) => {
            trace.set_response(
                resp.status,
                &resp.headers,
                serde_json::to_string(&resp.body).unwrap_or_default().len(),
                0, // round_trip logged inside execute_with_resilience
            );
            trace.end_phase(Some(&format!("HTTP {}", resp.status)));
            resp
        }
        Err(e) => {
            trace.fail_phase(&e.to_string());
            let finished = trace.finish_bridge_error(&e);
            tracing::warn!("{}", finished.summary());
            return Err(e);
        }
    };

    // ── 6. Appliquer les hooks post-réponse ──
    if !hooks.is_empty() {
        trace.start_phase("post_hooks");
        if let Err(e) = ctx.hooks.apply_post_hooks(hooks, &mut bridge_response) {
            trace.fail_phase(&e.to_string());
            trace.record_error("post_hooks", "HookFailed", &e.to_string(), None);
            let finished = trace.finish_bridge_error(&e);
            tracing::warn!("{}", finished.summary());
            return Err(e);
        }
        trace.end_phase(Some(&format!("hooks=[{}]", hooks.join(", "))));
    }

    // ── 7. Fermer le circuit breaker si succès ──
    ctx.close_circuit(provider_name);

    // ── 8. Finaliser la trace ──
    let value = if bridge_response.is_success() {
        bridge_response.into_body()
    } else {
        bridge_response.into_full_value()
    };

    let status = value
        .get("status")
        .and_then(|s| s.as_u64())
        .unwrap_or(200) as u16;

    let finished_trace = trace.finish_success(status);
    tracing::info!("{}", finished_trace.summary());

    Ok(BridgeCallResult {
        value,
        trace: finished_trace,
    })
}

// =========================================================================
// Exécution HTTP brute
// =========================================================================

/// Exécute une requête HTTP via reqwest.
async fn execute_http(
    ctx: &BridgeContext,
    req: &BridgeRequest,
) -> Result<(BridgeResponse, u64), BridgeError> {
    let method = parse_method(&req.method);
    let mut builder = ctx.http_client().request(method, &req.url);

    for (k, v) in &req.headers {
        builder = builder.header(k, v);
    }

    if let Some(ms) = req.timeout_ms {
        builder = builder.timeout(Duration::from_millis(ms));
    }

    if let Some(body) = &req.body {
        builder = builder.json(body);
    }

    let http_start = Instant::now();
    let resp = builder.send().await.map_err(BridgeError::from)?;
    let round_trip_ms = http_start.elapsed().as_millis() as u64;

    let parsed = response::parse_response(resp).await?;
    Ok((parsed, round_trip_ms))
}

/// Parse une string de méthode HTTP en reqwest::Method.
fn parse_method(method: &str) -> Method {
    match method.to_uppercase().as_str() {
        "GET" => Method::GET,
        "POST" => Method::POST,
        "PUT" => Method::PUT,
        "PATCH" => Method::PATCH,
        "DELETE" => Method::DELETE,
        "HEAD" => Method::HEAD,
        "OPTIONS" => Method::OPTIONS,
        "TRACE" => Method::TRACE,
        _ => Method::GET,
    }
}

// =========================================================================
// Exécution avec résilience
// =========================================================================

/// Exécute la requête avec retry, backoff, rate limiting et error mapping.
/// Chaque tentative est tracée dans le TraceBuilder.
async fn execute_with_resilience(
    ctx: &BridgeContext,
    request: &BridgeRequest,
    error_rules: &[BridgeErrorRule],
    provider_name: &str,
    operation_name: &str,
    trace: &mut TraceBuilder,
) -> Result<BridgeResponse, BridgeError> {
    let retry_rule = error_rules
        .iter()
        .find(|r| r.configuration.action == "retry" && r.status.is_active);

    let max_attempts = retry_rule.map(|r| r.resilience.max_attempts).unwrap_or(1);
    let backoff_ms = retry_rule.map(|r| r.resilience.backoff_ms).unwrap_or(1000);
    let exponential = retry_rule.map(|r| r.resilience.exponential).unwrap_or(true);

    let mut last_error: Option<BridgeError> = None;

    for attempt in 0..max_attempts {
        trace.increment_attempts();

        // ── Backoff ──
        if attempt > 0 && backoff_ms > 0 {
            let delay = if exponential {
                backoff_ms * (1u64 << attempt.saturating_sub(1))
            } else {
                backoff_ms
            };
            debug!(
                trace_id = %trace.trace_id(),
                attempt = attempt + 1,
                delay_ms = delay,
                "🔄 Retry backoff"
            );
            tokio::time::sleep(Duration::from_millis(delay)).await;
        }

        // ── Exécution HTTP ──
        match execute_http(ctx, request).await {
            Ok((resp, round_trip_ms)) => {
                let status = resp.status;

                trace.set_response(status, &resp.headers, 0, round_trip_ms);

                // ── Error mapping ──
                let matching_rule = error_rules.iter().find(|r| {
                    r.status.is_active && r.triggers.http_code == Some(status as i64)
                });

                if let Some(rule) = matching_rule {
                    match rule.configuration.action.as_str() {
                        "retry" if attempt < max_attempts - 1 => {
                            trace.record_error(
                                "http_execute",
                                "RetryableStatus",
                                &format!("HTTP {} — retrying", status),
                                Some(attempt + 1),
                            );
                            last_error = Some(BridgeError::HttpResponseError {
                                provider: provider_name.to_string(),
                                status,
                                message: format!("HTTP {} — will retry", status),
                            });
                            continue;
                        }
                        "stop" => {
                            let msg = rule.configuration.mapped_message.clone()
                                .unwrap_or_else(|| format!("Stopped at HTTP {}", status));
                            trace.record_error("http_execute", "StoppedByRule", &msg, Some(attempt + 1));
                            return Err(BridgeError::StoppedByRule { status, message: msg });
                        }
                        "ignore" => {
                            debug!(trace_id = %trace.trace_id(), "Erreur ignorée par règle");
                            return Ok(resp);
                        }
                        "map" => {
                            let msg = rule.configuration.mapped_message.clone()
                                .unwrap_or_else(|| format!("HTTP {}", status));
                            trace.record_error("http_execute", "MappedError", &msg, Some(attempt + 1));
                            return Err(BridgeError::MappedError { message: msg });
                        }
                        "circuit_break" => {
                            ctx.open_circuit(provider_name);
                            trace.record_error("http_execute", "CircuitBreak", "Circuit opened", Some(attempt + 1));
                            return Err(BridgeError::CircuitBreakerOpen {
                                provider: provider_name.to_string(),
                            });
                        }
                        _ => {}
                    }
                }

                // ── Erreur HTTP sans règle custom ──
                if status >= 400 {
                    if status >= 500 && attempt < max_attempts - 1 {
                        trace.record_error(
                            "http_execute",
                            "ServerError",
                            &format!("HTTP {} — retrying", status),
                            Some(attempt + 1),
                        );
                        last_error = Some(BridgeError::HttpResponseError {
                            provider: provider_name.to_string(),
                            status,
                            message: resp.body.to_string(),
                        });
                        continue;
                    }

                    trace.record_error(
                        "http_execute",
                        "HttpError",
                        &format!("HTTP {}", status),
                        Some(attempt + 1),
                    );
                    return Err(BridgeError::HttpResponseError {
                        provider: provider_name.to_string(),
                        status,
                        message: resp.body.to_string(),
                    });
                }

                return Ok(resp);
            }
            Err(e) => {
                trace.record_error(
                    "http_execute",
                    "NetworkError",
                    &e.to_string(),
                    Some(attempt + 1),
                );
                warn!(
                    trace_id = %trace.trace_id(),
                    attempt = attempt + 1,
                    error = %e,
                    "Requête Bridge échouée"
                );
                last_error = Some(e);

                if attempt >= max_attempts - 1 {
                    break;
                }
            }
        }
    }

    if max_attempts > 1 {
        Err(BridgeError::RetriesExhausted {
            provider: provider_name.to_string(),
            operation: operation_name.to_string(),
            attempts: max_attempts,
        })
    } else {
        Err(last_error.unwrap_or(BridgeError::Internal(
            "Bridge call failed with no error details".to_string(),
        )))
    }
}
