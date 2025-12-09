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

    /// Create a collection (calendar or folder)
    async fn create_collection(&self, path: &str, kind: ResourceKind) -> anyhow::Result<()>;

    /// Query a collection (REPORT)
    async fn query_collection(&self, path: &str, query: CalendarQuery) -> anyhow::Result<Vec<Resource>> {
        // Fetch all candidates
        let candidates = self.list_collection(path).await?;
        
        // Parse query range
        use chrono::{DateTime, Utc};
        let range_start = if let Some(s) = &query.start {
             crate::ical::parse_date(s).unwrap_or(Utc::now()) // Fallback or Error? 
        } else {
            // Unbounded start? use far past
            DateTime::parse_from_rfc3339("1900-01-01T00:00:00Z").unwrap().with_timezone(&Utc)
        };
        
        let range_end = if let Some(s) = &query.end {
             crate::ical::parse_date(s).unwrap_or(Utc::now())
        } else {
             // Unbounded end? use far future
             DateTime::parse_from_rfc3339("2100-01-01T00:00:00Z").unwrap().with_timezone(&Utc)
        };

        if query.start.is_none() && query.end.is_none() {
            return Ok(candidates);
        }

        let mut filtered = Vec::new();
        for mut res in candidates {
            if res.kind != ResourceKind::Object {
                // Keep collections/other? Usually query returns VEVENTs.
                // Assuming exclude non-objects from time-range filter or just include them?
                continue; 
            }

            // Ensure content is loaded
            let content = if let Some(c) = res.content.clone() {
                c
            } else {
                 if let Ok(Some(full_res)) = self.get_resource(&res.path).await {
                     if let Some(c) = full_res.content {
                         c
                     } else {
                         continue; // No content, skip
                     }
                 } else {
                     continue;
                 }
            };

            let text = String::from_utf8_lossy(&content);
            if let Ok(events) = crate::ical::events(&text) {
                let mut matched = false;
                for event in events {
                    if crate::ical::is_in_range(&event, range_start, range_end) {
                        matched = true;
                        break;
                    }
                }
                if matched {
                    // Optional: Use expanded occurrences? 
                    // RFC says return the VEVENT.
                    res.content = Some(content); // Store back content if fetched
                    filtered.push(res);
                }
            }
        }
        
        Ok(filtered) 
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CalendarQuery {
    pub start: Option<String>, // ISO8601/iCal format
    pub end: Option<String>,
    // In v2 we can add more filter fields
}
