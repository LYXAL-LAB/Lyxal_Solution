use async_trait::async_trait;
use serde::{Deserialize, Serialize};

/// Represents a resource (calendar, object, collection)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Resource {
    pub path: String,
    pub kind: ResourceKind,
    pub mime_type: String,
    pub etag: String,
    pub content: Option<Vec<u8>>, // Content if requested/small
    pub properties: std::collections::HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ResourceKind {
    Collection,
    Calendar,
    Object,
    Principal,
}

/// Interface for DAV storage backend
#[async_trait]
pub trait DavBackend: Send + Sync {
    /// Get a resource by path
    async fn get_resource(&self, path: &str) -> anyhow::Result<Option<Resource>>;
    
    /// List children of a collection
    async fn list_collection(&self, path: &str) -> anyhow::Result<Vec<Resource>>;
    
    /// Create or update a resource
    async fn put_resource(&self, path: &str, data: &[u8], mime: &str) -> anyhow::Result<String>;
    
    /// Delete a resource
    async fn delete_resource(&self, path: &str) -> anyhow::Result<()>;

    /// Query a collection (REPORT)
    async fn query_collection(&self, path: &str, query: CalendarQuery) -> anyhow::Result<Vec<Resource>> {
        // Default implementation: list and filter in memory? 
        // For trait definition, we can force implementation or provide default.
        // Providing default allows incremental update.
        let resources = self.list_collection(path).await?;
        // TODO: Filter logic here or let implementor do it?
        // Let's force implementor for now or just return all (stub).
        let _ = query; // Suppress unused warning
        Ok(resources) 
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarQuery {
    pub start: Option<String>, // ISO8601/iCal format
    pub end: Option<String>,
    // In v2 we can add more filter fields
}
