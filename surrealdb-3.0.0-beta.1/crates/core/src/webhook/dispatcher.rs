//! Webhook Dispatcher
//!
//! Orchestrates the webhook execution pipeline:
//! 1. Resolve webhook definition from registry
//! 2. Verify signature
//! 3. Parse payload
//! 4. Emit system events
//! 5. Execute handler (fn:: or EVENT)

use std::collections::HashMap;
use std::sync::Arc;

use super::error::{Result, WebhookError};
use super::registry::WebhookRegistry;
use super::types::{DispatchResult, WebhookContentType, WebhookDefinition, WebhookHandlerType, WebhookPayload};
use super::verifier::WebhookVerifier;

/// Webhook dispatcher for processing incoming webhook requests
pub struct WebhookDispatcher {
    registry: Arc<WebhookRegistry>,
}

impl WebhookDispatcher {
    /// Create a new dispatcher with the given registry
    pub fn new(registry: Arc<WebhookRegistry>) -> Self {
        Self { registry }
    }

    /// Dispatch a webhook request
    ///
    /// # Arguments
    /// * `ns` - Namespace
    /// * `db` - Database
    /// * `method` - HTTP method
    /// * `path` - Request path
    /// * `body` - Raw request body
    /// * `headers` - HTTP headers
    ///
    /// # Returns
    /// * `DispatchResult` - The result of the dispatch operation
    pub async fn dispatch(
        &self,
        ns: &str,
        db: &str,
        method: &str,
        path: &str,
        body: &[u8],
        headers: HashMap<String, String>,
    ) -> DispatchResult {
        // 1. Emit webhook:received event
        tracing::info!(
            event = "webhook:received",
            ns = %ns,
            db = %db,
            method = %method,
            path = %path,
            body_len = body.len(),
            "Webhook received"
        );

        // 2. Resolve webhook definition
        let webhook = match self.registry.get_by_path(ns, db, method, path).await {
            Some(w) => w,
            None => {
                tracing::warn!(
                    event = "webhook:not_found",
                    ns = %ns,
                    db = %db,
                    path = %path,
                    "Webhook definition not found"
                );
                return DispatchResult::rejected("Webhook not found", 404);
            }
        };

        // 3. Check if enabled
        if !webhook.enabled {
            tracing::warn!(
                event = "webhook:disabled",
                name = %webhook.name,
                "Webhook is disabled"
            );
            return DispatchResult::rejected("Webhook is disabled", 503);
        }

        // 4. Resolve secret (from environment or config)
        let secret = self.resolve_secret(&webhook).await;

        // 5. Verify signature
        match WebhookVerifier::verify(&webhook.verify, secret.as_deref(), body, &headers) {
            Ok(true) => {
                tracing::info!(
                    event = "webhook:verified",
                    name = %webhook.name,
                    verify_mode = ?webhook.verify,
                    "Webhook signature verified"
                );
            }
            Ok(false) => {
                tracing::warn!(
                    event = "webhook:rejected",
                    name = %webhook.name,
                    reason = "signature_mismatch",
                    "Webhook signature verification failed"
                );
                return DispatchResult::rejected("Invalid signature", 401);
            }
            Err(e) => {
                tracing::warn!(
                    event = "webhook:rejected",
                    name = %webhook.name,
                    error = %e,
                    "Webhook verification error"
                );
                return DispatchResult::rejected(e.to_string(), e.status_code());
            }
        }

        // 6. Parse payload
        let parsed_body = match self.parse_payload(&webhook.content_type, body) {
            Ok(p) => p,
            Err(e) => {
                tracing::error!(
                    event = "webhook:parse_error",
                    name = %webhook.name,
                    error = %e,
                    "Failed to parse webhook payload"
                );
                return DispatchResult::rejected(format!("Payload parse error: {}", e), 400);
            }
        };

        // 7. Build payload object
        let payload = WebhookPayload {
            path: path.to_string(),
            method: method.to_string(),
            body: parsed_body,
            headers: self.filter_headers(&headers),
            received_at: chrono::Utc::now(),
            webhook_name: webhook.name.clone(),
            namespace: ns.to_string(),
            database: db.to_string(),
        };

        // 8. Execute handler
        let result = self.execute_handler(&webhook, &payload).await;

        // 9. Emit completion event
        match &result {
            DispatchResult::Success { .. } => {
                tracing::info!(
                    event = "webhook:dispatched",
                    name = %webhook.name,
                    handler = ?webhook.handler,
                    "Webhook handler executed successfully"
                );
            }
            DispatchResult::Failed { error } => {
                tracing::error!(
                    event = "webhook:handler_failed",
                    name = %webhook.name,
                    error = %error,
                    "Webhook handler execution failed"
                );
            }
            _ => {}
        }

        result
    }

    /// Resolve secret from webhook definition
    async fn resolve_secret(&self, webhook: &WebhookDefinition) -> Option<String> {
        let secret_expr = webhook.secret.as_ref()?;

        // Handle $env.VAR_NAME pattern
        if secret_expr.starts_with("$env.") {
            let var_name = secret_expr.strip_prefix("$env.")?;
            return std::env::var(var_name).ok();
        }

        // Handle direct string (for testing, not recommended in production)
        Some(secret_expr.clone())
    }

    /// Parse payload based on content type
    fn parse_payload(&self, content_type: &WebhookContentType, body: &[u8]) -> Result<serde_json::Value> {
        match content_type {
            WebhookContentType::Json => {
                if body.is_empty() {
                    return Ok(serde_json::Value::Null);
                }
                serde_json::from_slice(body).map_err(|e| WebhookError::PayloadParseError {
                    reason: e.to_string(),
                })
            }
            WebhookContentType::Form => {
                // Simple form URL-encoded parsing
                let body_str = String::from_utf8_lossy(body);
                let form_data: HashMap<String, String> = body_str
                    .split('&')
                    .filter_map(|pair| {
                        let mut parts = pair.splitn(2, '=');
                        match (parts.next(), parts.next()) {
                            (Some(k), Some(v)) => {
                                // Simple URL decoding (just handle + as space)
                                let key = k.replace('+', " ");
                                let val = v.replace('+', " ");
                                Some((key, val))
                            }
                            _ => None,
                        }
                    })
                    .collect();
                Ok(serde_json::to_value(form_data).unwrap_or(serde_json::Value::Null))
            }
            WebhookContentType::Raw => {
                let text = String::from_utf8_lossy(body);
                Ok(serde_json::Value::String(text.to_string()))
            }
            WebhookContentType::Binary => {
                // Simple base64 encoding without external crate
                use base64::Engine as _;
                let encoded = base64::engine::general_purpose::STANDARD.encode(body);
                Ok(serde_json::json!({
                    "data": encoded,
                    "encoding": "base64",
                    "size": body.len()
                }))
            }
        }
    }

    /// Filter headers to include only safe, non-sensitive ones
    fn filter_headers(&self, headers: &HashMap<String, String>) -> HashMap<String, String> {
        let sensitive = ["authorization", "cookie", "set-cookie", "x-api-key"];
        headers
            .iter()
            .filter(|(k, _)| !sensitive.contains(&k.to_lowercase().as_str()))
            .map(|(k, v)| (k.clone(), v.clone()))
            .collect()
    }

    /// Execute the webhook handler
    async fn execute_handler(&self, webhook: &WebhookDefinition, _payload: &WebhookPayload) -> DispatchResult {
        match &webhook.handler {
            WebhookHandlerType::Function(func_name) => {
                // TODO: Execute function via datastore
                // For now, log the intent
                tracing::info!(
                    event = "webhook:dispatch_function",
                    function = %func_name,
                    webhook = %webhook.name,
                    "Dispatching to function handler"
                );
                
                // Placeholder: In production, this would call datastore.execute()
                // with the function and payload as parameters
                DispatchResult::success(Some(serde_json::json!({
                    "status": "dispatched",
                    "handler": func_name,
                    "webhook": webhook.name
                })))
            }
            WebhookHandlerType::Event(event_name) => {
                // TODO: Trigger DEFINE EVENT via datastore
                tracing::info!(
                    event = "webhook:dispatch_event",
                    event_name = %event_name,
                    webhook = %webhook.name,
                    "Dispatching to event handler"
                );
                
                // Placeholder: In production, this would trigger the event
                DispatchResult::success(Some(serde_json::json!({
                    "status": "dispatched",
                    "handler": format!("EVENT {}", event_name),
                    "webhook": webhook.name
                })))
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::webhook::types::WebhookVerifyMode;

    #[tokio::test]
    async fn test_dispatch_not_found() {
        let registry = Arc::new(WebhookRegistry::new());
        let dispatcher = WebhookDispatcher::new(registry);

        let result = dispatcher
            .dispatch("test", "test", "POST", "/unknown", b"", HashMap::new())
            .await;

        assert!(matches!(result, DispatchResult::Rejected { status_code: 404, .. }));
    }

    #[tokio::test]
    async fn test_dispatch_success() {
        let registry = Arc::new(WebhookRegistry::new());
        
        let webhook = WebhookDefinition {
            name: "test".to_string(),
            path: "/test".to_string(),
            method: "POST".to_string(),
            verify: WebhookVerifyMode::None,
            secret: None,
            content_type: WebhookContentType::Json,
            handler: WebhookHandlerType::Function("fn::test::handler".to_string()),
            enabled: true,
            comment: None,
            namespace: "test".to_string(),
            database: "test".to_string(),
        };
        
        registry.register(webhook).await;
        
        let dispatcher = WebhookDispatcher::new(registry);
        let result = dispatcher
            .dispatch("test", "test", "POST", "/test", b"{}", HashMap::new())
            .await;

        assert!(result.is_success());
    }
}
