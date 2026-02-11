//! Webhook Registry
//!
//! In-memory cache of active webhook definitions.
//! The registry is loaded from the KVS catalogue on boot and
//! updated dynamically when webhooks are defined/removed.

use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;

use super::types::WebhookDefinition;

/// Thread-safe webhook registry
#[derive(Debug, Default)]
pub struct WebhookRegistry {
    /// Webhooks indexed by registry key (ns:db:method:path)
    webhooks: RwLock<HashMap<String, WebhookDefinition>>,
}

impl WebhookRegistry {
    /// Create a new empty registry
    pub fn new() -> Self {
        Self {
            webhooks: RwLock::new(HashMap::new()),
        }
    }

    /// Register a webhook definition
    pub async fn register(&self, webhook: WebhookDefinition) {
        let key = webhook.registry_key();
        tracing::info!(
            event = "webhook:registered",
            name = %webhook.name,
            path = %webhook.path,
            key = %key,
            "Webhook registered in registry"
        );
        self.webhooks.write().await.insert(key, webhook);
    }

    /// Remove a webhook by name within a namespace/database scope
    pub async fn remove(&self, ns: &str, db: &str, name: &str) -> Option<WebhookDefinition> {
        let mut guard = self.webhooks.write().await;
        let key_to_remove = guard
            .iter()
            .find(|(_, v)| v.namespace == ns && v.database == db && v.name == name)
            .map(|(k, _)| k.clone());

        if let Some(key) = key_to_remove {
            tracing::info!(
                event = "webhook:removed",
                name = %name,
                ns = %ns,
                db = %db,
                "Webhook removed from registry"
            );
            guard.remove(&key)
        } else {
            None
        }
    }

    /// Get a webhook by path and method
    pub async fn get_by_path(&self, ns: &str, db: &str, method: &str, path: &str) -> Option<WebhookDefinition> {
        let key = format!("{}:{}:{}:{}", ns, db, method, path);
        self.webhooks.read().await.get(&key).cloned()
    }

    /// Get a webhook by name
    pub async fn get_by_name(&self, ns: &str, db: &str, name: &str) -> Option<WebhookDefinition> {
        self.webhooks
            .read()
            .await
            .values()
            .find(|w| w.namespace == ns && w.database == db && w.name == name)
            .cloned()
    }

    /// List all webhooks for a namespace/database
    pub async fn list(&self, ns: &str, db: &str) -> Vec<WebhookDefinition> {
        self.webhooks
            .read()
            .await
            .values()
            .filter(|w| w.namespace == ns && w.database == db)
            .cloned()
            .collect()
    }

    /// List all webhooks in the registry
    pub async fn list_all(&self) -> Vec<WebhookDefinition> {
        self.webhooks.read().await.values().cloned().collect()
    }

    /// Check if a webhook exists
    pub async fn exists(&self, ns: &str, db: &str, name: &str) -> bool {
        self.webhooks
            .read()
            .await
            .values()
            .any(|w| w.namespace == ns && w.database == db && w.name == name)
    }

    /// Clear all webhooks (used for testing or reload)
    pub async fn clear(&self) {
        self.webhooks.write().await.clear();
    }

    /// Get the number of registered webhooks
    pub async fn len(&self) -> usize {
        self.webhooks.read().await.len()
    }

    /// Check if the registry is empty
    pub async fn is_empty(&self) -> bool {
        self.webhooks.read().await.is_empty()
    }

    /// Enable or disable a webhook
    pub async fn set_enabled(&self, ns: &str, db: &str, name: &str, enabled: bool) -> bool {
        let mut guard = self.webhooks.write().await;
        for webhook in guard.values_mut() {
            if webhook.namespace == ns && webhook.database == db && webhook.name == name {
                webhook.enabled = enabled;
                tracing::info!(
                    event = if enabled { "webhook:enabled" } else { "webhook:disabled" },
                    name = %name,
                    ns = %ns,
                    db = %db,
                    "Webhook status changed"
                );
                return true;
            }
        }
        false
    }
}

/// Create a shared registry wrapped in Arc
pub fn shared_registry() -> Arc<WebhookRegistry> {
    Arc::new(WebhookRegistry::new())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::webhook::types::WebhookHandlerType;

    #[tokio::test]
    async fn test_registry_operations() {
        let registry = WebhookRegistry::new();
        
        let webhook = WebhookDefinition::new(
            "test_webhook",
            "/webhooks/test",
            WebhookHandlerType::Function("fn::test::handler".to_string()),
            "test_ns",
            "test_db",
        );
        
        // Register
        registry.register(webhook.clone()).await;
        assert_eq!(registry.len().await, 1);
        
        // Get by path
        let found = registry.get_by_path("test_ns", "test_db", "POST", "/webhooks/test").await;
        assert!(found.is_some());
        assert_eq!(found.unwrap().name, "test_webhook");
        
        // Get by name
        let found = registry.get_by_name("test_ns", "test_db", "test_webhook").await;
        assert!(found.is_some());
        
        // Remove
        let removed = registry.remove("test_ns", "test_db", "test_webhook").await;
        assert!(removed.is_some());
        assert!(registry.is_empty().await);
    }
}
