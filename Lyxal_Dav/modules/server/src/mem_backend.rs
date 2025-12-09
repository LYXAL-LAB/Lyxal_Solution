use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use async_trait::async_trait;
use lyxal_dav_core::backend::{DavBackend, Resource, ResourceKind};

/// Simple in-memory backend for testing purposes
#[derive(Clone)]
pub struct InMemoryBackend {
    store: Arc<RwLock<HashMap<String, Resource>>>,
}

impl InMemoryBackend {
    pub fn new() -> Self {
        Self {
            store: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    /// Helper to seed data
    pub async fn add_resource(&self, res: Resource) {
        let mut store = self.store.write().await;
        store.insert(res.path.clone(), res);
    }
}

#[async_trait]
impl DavBackend for InMemoryBackend {
    async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>> {
        let store = self.store.read().await;
        Ok(store.get(path).cloned())
    }

    async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>> {
        let guard = self.store.read().await;
        let mut resources = Vec::new();
        
        // Clone entries to avoid iterator issues
        let entries: Vec<(String, Resource)> = guard.iter().map(|(k, v)| (k.clone(), v.clone())).collect();
        
        let prefix = if path.ends_with('/') { path.to_string() } else { format!("{}/", path) };

        for (key, val) in entries {
            if key.starts_with(&prefix) {
                let suffix = &key[prefix.len()..];
                if !suffix.contains('/') {
                    resources.push(val);
                }
            }
        }
        
        Ok(resources)
    }

    async fn put_resource(&self, path: &str, data: &[u8], mime: &str) -> anyhow::Result<String> {
        let mut store = self.store.write().await;
        
        let etag = uuid::Uuid::new_v4().to_string(); // Simple ETag
        
        let res = Resource {
            path: path.to_string(),
            kind: ResourceKind::Object, // Assume object for PUT usually
            mime_type: mime.to_string(),
            etag: etag.clone(),
            content: Some(data.to_vec()),
            properties: HashMap::new(),
        };
        
        store.insert(path.to_string(), res);
        Ok(etag)
    }

    async fn delete_resource(&self, path: &str) -> anyhow::Result<()> {
        let mut store = self.store.write().await;
        store.remove(path);
        Ok(())
    }

    async fn create_collection(&self, path: &str, kind: ResourceKind) -> anyhow::Result<()> {
        let mut store = self.store.write().await;
        
        if store.contains_key(path) {
            return Err(anyhow::anyhow!("Resource already exists")); // Should be specialized error? Core handles mapping.
        }
        
        let res = Resource {
            path: path.to_string(),
            kind,
            mime_type: "".into(), // Collection has no mime usually, or specific one
            etag: uuid::Uuid::new_v4().to_string(),
            content: None,
            properties: HashMap::new(),
        };
        
        store.insert(path.to_string(), res);
        Ok(())
    }
    
    // Use default implementation for query_collection (filtering)
    // async fn query_collection(...)
}
