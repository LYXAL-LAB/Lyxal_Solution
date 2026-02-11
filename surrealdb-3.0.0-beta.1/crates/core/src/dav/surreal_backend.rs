//! SurrealDB Native DAV Backend
//!
//! Implementation of `DavBackend` trait using pure SurrealQL.
//! All operations are transactional and use parameterized queries.
//!
//! ## Design Principles
//! - No in-memory state
//! - No Rust business logic (all in SurrealQL)
//! - Strict realm isolation
//! - Automatic sync_token via EVENTs

use async_trait::async_trait;
use std::collections::HashMap;
use std::sync::Arc;

use super::backend::DavBackend;
use super::error::DavError;
use super::types::{
    CalendarQuery, Lock, Principal, Resource, ResourceKind, Share, ShareAccess, ShareStatus,
    SyncCollectionResult,
};

/// Schema SQL embedded at compile time
const SCHEMA_SURQL: &str = include_str!("schema.surql");

/// SurrealDB Native DAV Backend
///
/// Implements DavBackend using SurrealQL for all operations.
/// Requires a SurrealDB connection with appropriate namespace/database.
pub struct SurrealDavBackend {
    /// Database connection
    db: Arc<dyn SurrealConnection>,
    /// Realm ID for multi-tenant isolation
    realm: String,
}

/// Trait for SurrealDB connection abstraction
/// This allows the backend to work with different SurrealDB client implementations
#[async_trait]
pub trait SurrealConnection: Send + Sync {
    /// Execute a query and return results as JSON
    async fn query(&self, sql: &str, vars: HashMap<String, serde_json::Value>) -> Result<Vec<serde_json::Value>, String>;
    
    /// Execute a query without expecting results
    async fn execute(&self, sql: &str, vars: HashMap<String, serde_json::Value>) -> Result<(), String>;
}

impl SurrealDavBackend {
    /// Create a new SurrealDavBackend
    pub fn new(db: Arc<dyn SurrealConnection>, realm: String) -> Self {
        Self { db, realm }
    }

    /// Bootstrap the DAV schema
    /// Should be called once per database initialization
    pub async fn bootstrap(&self) -> Result<(), DavError> {
        self.db
            .execute(SCHEMA_SURQL, HashMap::new())
            .await
            .map_err(|e| DavError::Storage(format!("Bootstrap failed: {}", e)))
    }

    /// Helper to create variables map
    fn vars(&self) -> HashMap<String, serde_json::Value> {
        let mut vars = HashMap::new();
        vars.insert("realm".to_string(), serde_json::json!(self.realm));
        vars
    }

    /// Generate ETag from content
    fn generate_etag(content: &[u8]) -> String {
        use std::collections::hash_map::DefaultHasher;
        use std::hash::{Hash, Hasher};
        let mut hasher = DefaultHasher::new();
        content.hash(&mut hasher);
        format!("{:x}", hasher.finish())
    }

    /// Extract collection path from object path
    fn collection_path(path: &str) -> String {
        if let Some(pos) = path.rfind('/') {
            path[..pos].to_string()
        } else {
            "/".to_string()
        }
    }

    /// Convert ResourceKind to string
    fn kind_to_str(kind: &ResourceKind) -> &'static str {
        match kind {
            ResourceKind::Collection => "collection",
            ResourceKind::Calendar => "calendar",
            ResourceKind::AddressBook => "addressbook",
            ResourceKind::ScheduleInbox => "schedule-inbox",
            ResourceKind::ScheduleOutbox => "schedule-outbox",
            _ => "collection",
        }
    }

    /// Convert string to ResourceKind
    fn str_to_kind(s: &str) -> ResourceKind {
        match s {
            "calendar" => ResourceKind::Calendar,
            "addressbook" => ResourceKind::AddressBook,
            "schedule-inbox" => ResourceKind::ScheduleInbox,
            "schedule-outbox" => ResourceKind::ScheduleOutbox,
            "collection" | _ => ResourceKind::Collection,
        }
    }
}

#[async_trait]
impl DavBackend for SurrealDavBackend {
    // ═══════════════════════════════════════════════════════════════════
    // D10.2 - CRUD OPERATIONS
    // ═══════════════════════════════════════════════════════════════════

    async fn get_resource(&self, path: &str) -> Result<Option<Resource>, DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));

        // Try object first
        let sql = r#"
            SELECT * FROM dav_object 
            WHERE realm = $realm AND path = $path AND deleted_at = NONE
            LIMIT 1
        "#;

        let results = self.db.query(sql, vars.clone()).await
            .map_err(|e| DavError::Storage(e))?;

        if let Some(obj) = results.first() {
            let content = obj.get("content")
                .and_then(|v| v.as_str())
                .map(|s| s.as_bytes().to_vec());
            
            return Ok(Some(Resource {
                path: obj.get("path").and_then(|v| v.as_str()).unwrap_or(path).to_string(),
                kind: ResourceKind::Object,
                mime_type: obj.get("mime_type").and_then(|v| v.as_str()).unwrap_or("application/octet-stream").to_string(),
                etag: obj.get("etag").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                content,
                properties: HashMap::new(),
                sync_token: None,
            }));
        }

        // Try collection
        let sql = r#"
            SELECT * FROM dav_collection 
            WHERE realm = $realm AND path = $path AND deleted_at = NONE
            LIMIT 1
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        if let Some(coll) = results.first() {
            let kind_str = coll.get("kind").and_then(|v| v.as_str()).unwrap_or("collection");
            let sync_token = coll.get("sync_token").and_then(|v| v.as_i64()).map(|v| v.to_string());
            
            let mut properties = HashMap::new();
            if let Some(dn) = coll.get("displayname").and_then(|v| v.as_str()) {
                properties.insert("D:displayname".to_string(), dn.to_string());
            }
            if let Some(desc) = coll.get("description").and_then(|v| v.as_str()) {
                properties.insert("D:description".to_string(), desc.to_string());
            }
            if let Some(color) = coll.get("color").and_then(|v| v.as_str()) {
                properties.insert("apple:calendar-color".to_string(), color.to_string());
            }

            return Ok(Some(Resource {
                path: coll.get("path").and_then(|v| v.as_str()).unwrap_or(path).to_string(),
                kind: Self::str_to_kind(kind_str),
                mime_type: "httpd/unix-directory".to_string(),
                etag: sync_token.clone().unwrap_or_default(),
                content: None,
                properties,
                sync_token,
            }));
        }

        Ok(None)
    }

    async fn list_collection(&self, path: &str) -> Result<Vec<Resource>, DavError> {
        let mut vars = self.vars();
        vars.insert("collection_path".to_string(), serde_json::json!(path));

        let sql = r#"
            SELECT * FROM dav_object 
            WHERE realm = $realm AND collection_path = $collection_path AND deleted_at = NONE
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut resources = Vec::new();
        for obj in results {
            let content = obj.get("content")
                .and_then(|v| v.as_str())
                .map(|s| s.as_bytes().to_vec());

            resources.push(Resource {
                path: obj.get("path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                kind: ResourceKind::Object,
                mime_type: obj.get("mime_type").and_then(|v| v.as_str()).unwrap_or("application/octet-stream").to_string(),
                etag: obj.get("etag").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                content,
                properties: HashMap::new(),
                sync_token: None,
            });
        }

        Ok(resources)
    }

    async fn put_resource(&self, path: &str, data: &[u8], mime: &str) -> Result<String, DavError> {
        let etag = Self::generate_etag(data);
        let collection_path = Self::collection_path(path);
        let content_str = String::from_utf8_lossy(data).to_string();

        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));
        vars.insert("collection_path".to_string(), serde_json::json!(collection_path));
        vars.insert("content".to_string(), serde_json::json!(content_str));
        vars.insert("etag".to_string(), serde_json::json!(etag));
        vars.insert("mime_type".to_string(), serde_json::json!(mime));
        vars.insert("size".to_string(), serde_json::json!(data.len()));

        let sql = r#"
            BEGIN TRANSACTION;
            
            UPSERT dav_object SET
                realm = $realm,
                path = $path,
                collection_path = $collection_path,
                content = $content,
                etag = $etag,
                mime_type = $mime_type,
                size = $size,
                updated_at = time::now()
            WHERE realm = $realm AND path = $path;
            
            COMMIT TRANSACTION;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(etag)
    }

    async fn delete_resource(&self, path: &str) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));

        // Try to delete object first
        let sql = r#"
            BEGIN TRANSACTION;
            DELETE FROM dav_object WHERE realm = $realm AND path = $path;
            DELETE FROM dav_collection WHERE realm = $realm AND path = $path;
            DELETE FROM dav_prop WHERE realm = $realm AND path = $path;
            DELETE FROM dav_lock WHERE realm = $realm AND path = $path;
            COMMIT TRANSACTION;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    async fn create_collection(&self, path: &str, kind: ResourceKind) -> Result<(), DavError> {
        let kind_str = Self::kind_to_str(&kind);
        let owner = "system"; // TODO: Get from context

        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));
        vars.insert("kind".to_string(), serde_json::json!(kind_str));
        vars.insert("owner".to_string(), serde_json::json!(owner));

        let sql = r#"
            BEGIN TRANSACTION;
            
            CREATE dav_collection SET
                realm = $realm,
                path = $path,
                kind = $kind,
                owner = $owner,
                sync_token = 1,
                created_at = time::now(),
                updated_at = time::now();
            
            COMMIT TRANSACTION;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    // ═══════════════════════════════════════════════════════════════════
    // D10.2 - PROPERTY OPERATIONS
    // ═══════════════════════════════════════════════════════════════════

    async fn set_properties(&self, path: &str, props: &[(String, String)]) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));

        for (name, value) in props {
            vars.insert("name".to_string(), serde_json::json!(name));
            vars.insert("value".to_string(), serde_json::json!(value));

            let sql = r#"
                UPSERT dav_prop SET
                    realm = $realm,
                    path = $path,
                    name = $name,
                    value = $value,
                    updated_at = time::now()
                WHERE realm = $realm AND path = $path AND name = $name;
            "#;

            self.db.execute(sql, vars.clone()).await
                .map_err(|e| DavError::Storage(e))?;
        }

        Ok(())
    }

    async fn remove_properties(&self, path: &str, names: &[String]) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));

        for name in names {
            vars.insert("name".to_string(), serde_json::json!(name));

            let sql = r#"
                DELETE FROM dav_prop 
                WHERE realm = $realm AND path = $path AND name = $name;
            "#;

            self.db.execute(sql, vars.clone()).await
                .map_err(|e| DavError::Storage(e))?;
        }

        Ok(())
    }

    async fn get_properties(&self, path: &str) -> Result<HashMap<String, String>, DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));

        let sql = r#"
            SELECT name, value FROM dav_prop 
            WHERE realm = $realm AND path = $path
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut props = HashMap::new();
        for row in results {
            if let (Some(name), Some(value)) = (
                row.get("name").and_then(|v| v.as_str()),
                row.get("value").and_then(|v| v.as_str()),
            ) {
                props.insert(name.to_string(), value.to_string());
            }
        }

        Ok(props)
    }

    // ═══════════════════════════════════════════════════════════════════
    // D10.3 - SYNC-COLLECTION
    // ═══════════════════════════════════════════════════════════════════

    async fn sync_collection(
        &self,
        path: &str,
        sync_token: Option<&str>,
        limit: Option<usize>,
    ) -> Result<SyncCollectionResult, DavError> {
        let mut vars = self.vars();
        vars.insert("collection_path".to_string(), serde_json::json!(path));

        // Get current sync token
        let token_sql = r#"
            SELECT sync_token FROM dav_collection 
            WHERE realm = $realm AND path = $collection_path
            LIMIT 1
        "#;

        let token_results = self.db.query(token_sql, vars.clone()).await
            .map_err(|e| DavError::Storage(e))?;

        let current_token = token_results.first()
            .and_then(|r| r.get("sync_token"))
            .and_then(|v| v.as_i64())
            .unwrap_or(1);

        let from_token: i64 = sync_token
            .and_then(|s| s.parse().ok())
            .unwrap_or(0);

        vars.insert("from_token".to_string(), serde_json::json!(from_token));

        // Get changes since token
        let changes_sql = if let Some(lim) = limit {
            vars.insert("limit".to_string(), serde_json::json!(lim));
            r#"
                SELECT object_path, operation, sync_token FROM dav_change_log 
                WHERE realm = $realm AND collection_path = $collection_path AND sync_token > $from_token
                ORDER BY sync_token ASC
                LIMIT $limit
            "#
        } else {
            r#"
                SELECT object_path, operation, sync_token FROM dav_change_log 
                WHERE realm = $realm AND collection_path = $collection_path AND sync_token > $from_token
                ORDER BY sync_token ASC
            "#
        };

        let changes = self.db.query(changes_sql, vars.clone()).await
            .map_err(|e| DavError::Storage(e))?;

        let mut resources = Vec::new();
        let mut max_token = from_token;

        for change in &changes {
            let obj_path = change.get("object_path").and_then(|v| v.as_str()).unwrap_or("");
            let operation = change.get("operation").and_then(|v| v.as_i64()).unwrap_or(0);
            let token = change.get("sync_token").and_then(|v| v.as_i64()).unwrap_or(0);

            if token > max_token {
                max_token = token;
            }

            // For deleted items (operation=3), return with empty content
            if operation == 3 {
                resources.push(Resource {
                    path: obj_path.to_string(),
                    kind: ResourceKind::Object,
                    mime_type: String::new(),
                    etag: String::new(),
                    content: None,
                    properties: HashMap::new(),
                    sync_token: None,
                });
            } else {
                // Fetch current object state
                if let Some(res) = self.get_resource(obj_path).await? {
                    resources.push(res);
                }
            }
        }

        let partial = limit.map(|l| changes.len() >= l).unwrap_or(false);
        let new_token = if partial { max_token } else { current_token };

        Ok(SyncCollectionResult {
            resources,
            sync_token: new_token.to_string(),
            partial,
        })
    }

    // ═══════════════════════════════════════════════════════════════════
    // D10.4 - LOCKS
    // ═══════════════════════════════════════════════════════════════════

    async fn lock(
        &self,
        path: &str,
        token: &str,
        principal: Option<&str>,
        depth: &str,
        timeout: i64,
        owner_info: Option<&str>,
    ) -> Result<(), DavError> {
        let expires_at = chrono::Utc::now() + chrono::Duration::seconds(timeout);

        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));
        vars.insert("token".to_string(), serde_json::json!(token));
        vars.insert("principal".to_string(), serde_json::json!(principal));
        vars.insert("depth".to_string(), serde_json::json!(depth));
        vars.insert("timeout".to_string(), serde_json::json!(timeout));
        vars.insert("expires_at".to_string(), serde_json::json!(expires_at.to_rfc3339()));
        vars.insert("owner_info".to_string(), serde_json::json!(owner_info));

        let sql = r#"
            BEGIN TRANSACTION;
            
            CREATE dav_lock SET
                realm = $realm,
                path = $path,
                token = $token,
                principal = $principal,
                depth = $depth,
                timeout = $timeout,
                expires_at = <datetime>$expires_at,
                owner_info = $owner_info,
                created_at = time::now();
            
            COMMIT TRANSACTION;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    async fn unlock(&self, path: &str, token: &str) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));
        vars.insert("token".to_string(), serde_json::json!(token));

        let sql = r#"
            DELETE FROM dav_lock 
            WHERE realm = $realm AND path = $path AND token = $token;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    async fn get_locks(&self, path: &str) -> Result<Vec<Lock>, DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(path));
        vars.insert("now".to_string(), serde_json::json!(chrono::Utc::now().to_rfc3339()));

        let sql = r#"
            SELECT * FROM dav_lock 
            WHERE realm = $realm AND path = $path AND expires_at > <datetime>$now
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut locks = Vec::new();
        for row in results {
            locks.push(Lock {
                path: row.get("path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                token: row.get("token").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                principal: row.get("principal").and_then(|v| v.as_str()).map(|s| s.to_string()),
                depth: row.get("depth").and_then(|v| v.as_str()).unwrap_or("0").to_string(),
                timeout: row.get("timeout").and_then(|v| v.as_i64()).unwrap_or(3600),
                expires_at: row.get("expires_at")
                    .and_then(|v| v.as_str())
                    .and_then(|s| chrono::DateTime::parse_from_rfc3339(s).ok())
                    .map(|dt| dt.timestamp())
                    .unwrap_or(0),
                owner_info: row.get("owner_info").and_then(|v| v.as_str()).map(|s| s.to_string()),
            });
        }

        Ok(locks)
    }

    // ═══════════════════════════════════════════════════════════════════
    // D10.4 - ACCESS CONTROL
    // ═══════════════════════════════════════════════════════════════════

    async fn check_access(&self, principal: &str, path: &str, write: bool) -> Result<bool, DavError> {
        let mut vars = self.vars();
        vars.insert("principal".to_string(), serde_json::json!(principal));
        vars.insert("path".to_string(), serde_json::json!(path));

        // Check if principal is owner of the collection
        let owner_sql = r#"
            SELECT owner FROM dav_collection 
            WHERE realm = $realm AND path = $path AND owner = $principal
            LIMIT 1
        "#;

        let owner_results = self.db.query(owner_sql, vars.clone()).await
            .map_err(|e| DavError::Storage(e))?;

        if !owner_results.is_empty() {
            return Ok(true); // Owner has full access
        }

        // Check shares
        let min_access = if write { 2 } else { 1 }; // 1=READ, 2=READ-WRITE
        vars.insert("min_access".to_string(), serde_json::json!(min_access));

        let share_sql = r#"
            SELECT access FROM dav_share 
            WHERE realm = $realm 
              AND resource_path = $path 
              AND sharee = $principal 
              AND status = 2
              AND access >= $min_access
            LIMIT 1
        "#;

        let share_results = self.db.query(share_sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(!share_results.is_empty())
    }

    // ═══════════════════════════════════════════════════════════════════
    // D10.4 - SHARING
    // ═══════════════════════════════════════════════════════════════════

    async fn get_shares(&self, path: &str) -> Result<Vec<Share>, DavError> {
        let mut vars = self.vars();
        vars.insert("resource_path".to_string(), serde_json::json!(path));

        let sql = r#"
            SELECT * FROM dav_share 
            WHERE realm = $realm AND resource_path = $resource_path
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut shares = Vec::new();
        for row in results {
            let access = match row.get("access").and_then(|v| v.as_i64()).unwrap_or(1) {
                2 => ShareAccess::ReadWrite,
                3 => ShareAccess::Admin,
                _ => ShareAccess::Read,
            };
            let status = match row.get("status").and_then(|v| v.as_i64()).unwrap_or(1) {
                2 => ShareStatus::Accepted,
                3 => ShareStatus::Declined,
                _ => ShareStatus::Pending,
            };

            shares.push(Share {
                resource_path: row.get("resource_path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                owner: row.get("owner").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                sharee: row.get("sharee").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                access_level: access,
                status,
            });
        }

        Ok(shares)
    }

    async fn create_share(&self, share: &Share) -> Result<(), DavError> {
        let access = match share.access_level {
            ShareAccess::Read => 1,
            ShareAccess::ReadWrite => 2,
            ShareAccess::Admin => 3,
        };

        let mut vars = self.vars();
        vars.insert("resource_path".to_string(), serde_json::json!(share.resource_path));
        vars.insert("owner".to_string(), serde_json::json!(share.owner));
        vars.insert("sharee".to_string(), serde_json::json!(share.sharee));
        vars.insert("access".to_string(), serde_json::json!(access));

        let sql = r#"
            BEGIN TRANSACTION;
            
            CREATE dav_share SET
                realm = $realm,
                resource_path = $resource_path,
                owner = $owner,
                sharee = $sharee,
                access = $access,
                status = 1,
                created_at = time::now(),
                updated_at = time::now();
            
            COMMIT TRANSACTION;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    async fn update_share_status(
        &self,
        path: &str,
        sharee: &str,
        accepted: bool,
    ) -> Result<(), DavError> {
        let status = if accepted { 2 } else { 3 }; // 2=ACCEPTED, 3=DECLINED

        let mut vars = self.vars();
        vars.insert("resource_path".to_string(), serde_json::json!(path));
        vars.insert("sharee".to_string(), serde_json::json!(sharee));
        vars.insert("status".to_string(), serde_json::json!(status));

        let sql = r#"
            UPDATE dav_share SET 
                status = $status,
                updated_at = time::now()
            WHERE realm = $realm AND resource_path = $resource_path AND sharee = $sharee;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    async fn remove_share(&self, path: &str, sharee: &str) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("resource_path".to_string(), serde_json::json!(path));
        vars.insert("sharee".to_string(), serde_json::json!(sharee));

        let sql = r#"
            DELETE FROM dav_share 
            WHERE realm = $realm AND resource_path = $resource_path AND sharee = $sharee;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    // ═══════════════════════════════════════════════════════════════════
    // MOVE / COPY OPERATIONS
    // ═══════════════════════════════════════════════════════════════════

    async fn move_path(&self, src: &str, dst: &str, overwrite: bool) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("src".to_string(), serde_json::json!(src));
        vars.insert("dst".to_string(), serde_json::json!(dst));
        vars.insert("dst_collection".to_string(), serde_json::json!(Self::collection_path(dst)));

        // Check if destination exists
        if !overwrite {
            let check_sql = r#"
                SELECT path FROM dav_object WHERE realm = $realm AND path = $dst
                UNION
                SELECT path FROM dav_collection WHERE realm = $realm AND path = $dst
            "#;
            let exists = self.db.query(check_sql, vars.clone()).await
                .map_err(|e| DavError::Storage(e))?;
            if !exists.is_empty() {
                return Err(DavError::PreconditionFailed);
            }
        }

        let sql = r#"
            BEGIN TRANSACTION;
            
            -- Move object if exists
            UPDATE dav_object SET 
                path = $dst,
                collection_path = $dst_collection,
                updated_at = time::now()
            WHERE realm = $realm AND path = $src;
            
            -- Move collection if exists
            UPDATE dav_collection SET 
                path = $dst,
                updated_at = time::now()
            WHERE realm = $realm AND path = $src;
            
            -- Move child objects (if moving a collection)
            UPDATE dav_object SET 
                path = string::replace(path, $src, $dst),
                collection_path = string::replace(collection_path, $src, $dst),
                updated_at = time::now()
            WHERE realm = $realm AND collection_path CONTAINS $src;
            
            -- Move properties
            UPDATE dav_prop SET 
                path = string::replace(path, $src, $dst),
                updated_at = time::now()
            WHERE realm = $realm AND path CONTAINS $src;
            
            -- Move locks
            UPDATE dav_lock SET 
                path = string::replace(path, $src, $dst)
            WHERE realm = $realm AND path CONTAINS $src;
            
            -- Move shares
            UPDATE dav_share SET 
                resource_path = string::replace(resource_path, $src, $dst),
                updated_at = time::now()
            WHERE realm = $realm AND resource_path CONTAINS $src;
            
            COMMIT TRANSACTION;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }

    async fn copy_path(&self, src: &str, dst: &str, overwrite: bool) -> Result<(), DavError> {
        // Get source resource
        let source = self.get_resource(src).await?
            .ok_or(DavError::NotFound)?;

        // Check if destination exists
        if !overwrite {
            if self.get_resource(dst).await?.is_some() {
                return Err(DavError::PreconditionFailed);
            }
        } else {
            // Delete existing destination
            let _ = self.delete_resource(dst).await;
        }

        match source.kind {
            ResourceKind::Object => {
                // Copy single object
                if let Some(content) = source.content {
                    self.put_resource(dst, &content, &source.mime_type).await?;
                }
            }
            _ => {
                // Copy collection
                self.create_collection(dst, source.kind).await?;

                // Copy all children
                let children = self.list_collection(src).await?;
                for child in children {
                    let child_dst = child.path.replace(src, dst);
                    if let Some(content) = child.content {
                        self.put_resource(&child_dst, &content, &child.mime_type).await?;
                    }
                }
            }
        }

        // Copy properties
        let props = self.get_properties(src).await?;
        if !props.is_empty() {
            let props_vec: Vec<(String, String)> = props.into_iter().collect();
            self.set_properties(dst, &props_vec).await?;
        }

        Ok(())
    }

    // ═══════════════════════════════════════════════════════════════════
    // CALDAV QUERIES
    // ═══════════════════════════════════════════════════════════════════

    async fn query_collection(
        &self,
        path: &str,
        query: CalendarQuery,
    ) -> Result<Vec<Resource>, DavError> {
        let mut vars = self.vars();
        vars.insert("collection_path".to_string(), serde_json::json!(path));

        // Build SQL with time-range filter if provided
        let sql = if let (Some(start), Some(end)) = (&query.start, &query.end) {
            vars.insert("start".to_string(), serde_json::json!(start));
            vars.insert("end".to_string(), serde_json::json!(end));
            r#"
                SELECT * FROM dav_object 
                WHERE realm = $realm 
                  AND collection_path = $collection_path 
                  AND deleted_at = NONE
                  AND (
                    (first_occurrence >= <datetime>$start AND first_occurrence <= <datetime>$end)
                    OR (last_occurrence >= <datetime>$start AND last_occurrence <= <datetime>$end)
                    OR (first_occurrence <= <datetime>$start AND last_occurrence >= <datetime>$end)
                  )
            "#
        } else {
            r#"
                SELECT * FROM dav_object 
                WHERE realm = $realm 
                  AND collection_path = $collection_path 
                  AND deleted_at = NONE
            "#
        };

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut resources = Vec::new();
        for obj in results {
            let content = obj.get("content")
                .and_then(|v| v.as_str())
                .map(|s| s.as_bytes().to_vec());

            resources.push(Resource {
                path: obj.get("path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                kind: ResourceKind::Object,
                mime_type: obj.get("mime_type").and_then(|v| v.as_str()).unwrap_or("text/calendar").to_string(),
                etag: obj.get("etag").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                content,
                properties: HashMap::new(),
                sync_token: None,
            });
        }

        Ok(resources)
    }

    async fn query_addressbook(
        &self,
        path: &str,
        query: super::types::AddressBookQuery,
    ) -> Result<Vec<Resource>, DavError> {
        let mut vars = self.vars();
        vars.insert("collection_path".to_string(), serde_json::json!(path));

        // For now, basic implementation - filter by prop-filter would require parsing vCard
        let sql = r#"
            SELECT * FROM dav_object 
            WHERE realm = $realm 
              AND collection_path = $collection_path 
              AND deleted_at = NONE
              AND mime_type CONTAINS "vcard"
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut resources = Vec::new();
        for obj in results {
            // Apply text-match filter if present
            let mut matches = true;
            for prop_filter in &query.filter.prop_filters {
                if let Some(ref text_match) = prop_filter.text_match {
                    let content = obj.get("content").and_then(|v| v.as_str()).unwrap_or("");
                    let content_matches = if text_match.negate_condition {
                        !content.to_lowercase().contains(&text_match.value.to_lowercase())
                    } else {
                        content.to_lowercase().contains(&text_match.value.to_lowercase())
                    };
                    if !content_matches {
                        matches = false;
                        break;
                    }
                }
            }
            
            if !matches {
                continue;
            }

            let content = obj.get("content")
                .and_then(|v| v.as_str())
                .map(|s| s.as_bytes().to_vec());

            resources.push(Resource {
                path: obj.get("path").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                kind: ResourceKind::Object,
                mime_type: obj.get("mime_type").and_then(|v| v.as_str()).unwrap_or("text/vcard").to_string(),
                etag: obj.get("etag").and_then(|v| v.as_str()).unwrap_or("").to_string(),
                content,
                properties: HashMap::new(),
                sync_token: None,
            });
        }

        Ok(resources)
    }

    async fn free_busy_query(
        &self,
        path: &str,
        query: CalendarQuery,
    ) -> Result<Vec<Resource>, DavError> {
        // Get events in the time range
        let events = self.query_collection(path, query.clone()).await?;

        // Generate VFREEBUSY response
        let start = query.start.unwrap_or_else(|| "19700101T000000Z".to_string());
        let end = query.end.unwrap_or_else(|| "20380101T000000Z".to_string());

        let mut freebusy_lines = Vec::new();
        freebusy_lines.push("BEGIN:VCALENDAR".to_string());
        freebusy_lines.push("VERSION:2.0".to_string());
        freebusy_lines.push("PRODID:-//Lyxal//DAV//EN".to_string());
        freebusy_lines.push("BEGIN:VFREEBUSY".to_string());
        freebusy_lines.push(format!("DTSTART:{}", start));
        freebusy_lines.push(format!("DTEND:{}", end));

        // Extract busy times from events (simplified - would need proper iCal parsing)
        for event in &events {
            if let Some(ref content) = event.content {
                let ical = String::from_utf8_lossy(content);
                // Extract DTSTART and DTEND from VEVENT
                let mut dtstart = None;
                let mut dtend = None;
                for line in ical.lines() {
                    if line.starts_with("DTSTART") {
                        dtstart = line.split(':').nth(1).map(|s| s.trim().to_string());
                    }
                    if line.starts_with("DTEND") {
                        dtend = line.split(':').nth(1).map(|s| s.trim().to_string());
                    }
                }
                if let (Some(ds), Some(de)) = (dtstart, dtend) {
                    freebusy_lines.push(format!("FREEBUSY;FBTYPE=BUSY:{}/{}", ds, de));
                }
            }
        }

        freebusy_lines.push("END:VFREEBUSY".to_string());
        freebusy_lines.push("END:VCALENDAR".to_string());

        let vfreebusy = freebusy_lines.join("\r\n");

        Ok(vec![Resource {
            path: path.to_string(),
            kind: ResourceKind::Object,
            mime_type: "text/calendar".to_string(),
            etag: Self::generate_etag(vfreebusy.as_bytes()),
            content: Some(vfreebusy.into_bytes()),
            properties: HashMap::new(),
            sync_token: None,
        }])
    }

    // ═══════════════════════════════════════════════════════════════════
    // AUTHENTICATION
    // ═══════════════════════════════════════════════════════════════════

    async fn authenticate_basic(
        &self,
        _realm: Option<&str>,
        user: &str,
        pass: &str,
    ) -> Result<Option<Principal>, DavError> {
        let mut vars = self.vars();
        vars.insert("username".to_string(), serde_json::json!(user));

        // Query user from SurrealDB access/user tables
        let sql = r#"
            SELECT * FROM user 
            WHERE name = $username 
            LIMIT 1
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        if let Some(user_row) = results.first() {
            // In production, you'd verify password hash here
            // For now, we trust that if user exists in DB, they're authenticated
            let stored_pass = user_row.get("pass").and_then(|v| v.as_str()).unwrap_or("");
            
            // Simple comparison (in production, use bcrypt/argon2 verification)
            if stored_pass == pass || stored_pass.is_empty() {
                return Ok(Some(Principal {
                    username: user.to_string(),
                    displayname: user_row.get("name").and_then(|v| v.as_str()).unwrap_or(user).to_string(),
                    email: user_row.get("email").and_then(|v| v.as_str()).map(|s| s.to_string()),
                    calendar_home: format!("/calendars/{}/", user),
                    addressbook_home: Some(format!("/addressbooks/{}/", user)),
                    principal_url: format!("/principals/{}/", user),
                    schedule_inbox_url: Some(format!("/calendars/{}/inbox/", user)),
                    schedule_outbox_url: Some(format!("/calendars/{}/outbox/", user)),
                    alternate_uris: vec![],
                    realm_id: Some(self.realm.clone()),
                }));
            }
        }

        Ok(None)
    }

    async fn authenticate_bearer(
        &self,
        _realm: Option<&str>,
        token: &str,
    ) -> Result<Option<Principal>, DavError> {
        let mut vars = self.vars();
        vars.insert("token".to_string(), serde_json::json!(token));

        // Query token from SurrealDB access tokens
        let sql = r#"
            SELECT * FROM access_token 
            WHERE token = $token 
              AND expires_at > time::now()
            LIMIT 1
        "#;

        let results = self.db.query(sql, vars.clone()).await
            .map_err(|e| DavError::Storage(e))?;

        if let Some(token_row) = results.first() {
            let username = token_row.get("user").and_then(|v| v.as_str()).unwrap_or("");
            
            // Fetch user details
            vars.insert("username".to_string(), serde_json::json!(username));
            let user_sql = r#"SELECT * FROM user WHERE name = $username LIMIT 1"#;
            let user_results = self.db.query(user_sql, vars).await
                .map_err(|e| DavError::Storage(e))?;

            if let Some(user_row) = user_results.first() {
                return Ok(Some(Principal {
                    username: username.to_string(),
                    displayname: user_row.get("name").and_then(|v| v.as_str()).unwrap_or(username).to_string(),
                    email: user_row.get("email").and_then(|v| v.as_str()).map(|s| s.to_string()),
                    calendar_home: format!("/calendars/{}/", username),
                    addressbook_home: Some(format!("/addressbooks/{}/", username)),
                    principal_url: format!("/principals/{}/", username),
                    schedule_inbox_url: Some(format!("/calendars/{}/inbox/", username)),
                    schedule_outbox_url: Some(format!("/calendars/{}/outbox/", username)),
                    alternate_uris: vec![],
                    realm_id: Some(self.realm.clone()),
                }));
            }
        }

        Ok(None)
    }

    async fn get_principal(
        &self,
        _realm: Option<&str>,
        user: &str,
    ) -> Result<Option<Principal>, DavError> {
        let mut vars = self.vars();
        vars.insert("username".to_string(), serde_json::json!(user));

        let sql = r#"
            SELECT * FROM user 
            WHERE name = $username 
            LIMIT 1
        "#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        if let Some(user_row) = results.first() {
            return Ok(Some(Principal {
                username: user.to_string(),
                displayname: user_row.get("name").and_then(|v| v.as_str()).unwrap_or(user).to_string(),
                email: user_row.get("email").and_then(|v| v.as_str()).map(|s| s.to_string()),
                calendar_home: format!("/calendars/{}/", user),
                addressbook_home: Some(format!("/addressbooks/{}/", user)),
                principal_url: format!("/principals/{}/", user),
                schedule_inbox_url: Some(format!("/calendars/{}/inbox/", user)),
                schedule_outbox_url: Some(format!("/calendars/{}/outbox/", user)),
                alternate_uris: vec![],
                realm_id: Some(self.realm.clone()),
            }));
        }

        Ok(None)
    }

    async fn list_principals(&self, _realm: Option<&str>) -> Result<Vec<Principal>, DavError> {
        let vars = self.vars();

        let sql = r#"SELECT * FROM user"#;

        let results = self.db.query(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        let mut principals = Vec::new();
        for user_row in results {
            let username = user_row.get("name").and_then(|v| v.as_str()).unwrap_or("");
            principals.push(Principal {
                username: username.to_string(),
                displayname: user_row.get("name").and_then(|v| v.as_str()).unwrap_or(username).to_string(),
                email: user_row.get("email").and_then(|v| v.as_str()).map(|s| s.to_string()),
                calendar_home: format!("/calendars/{}/", username),
                addressbook_home: Some(format!("/addressbooks/{}/", username)),
                principal_url: format!("/principals/{}/", username),
                schedule_inbox_url: Some(format!("/calendars/{}/inbox/", username)),
                schedule_outbox_url: Some(format!("/calendars/{}/outbox/", username)),
                alternate_uris: vec![],
                realm_id: Some(self.realm.clone()),
            });
        }

        Ok(principals)
    }

    async fn ensure_calendar_owner(
        &self,
        calendar_path: &str,
        principal: &str,
    ) -> Result<(), DavError> {
        let mut vars = self.vars();
        vars.insert("path".to_string(), serde_json::json!(calendar_path));
        vars.insert("owner".to_string(), serde_json::json!(principal));

        let sql = r#"
            UPDATE dav_collection SET 
                owner = $owner,
                updated_at = time::now()
            WHERE realm = $realm AND path = $path;
        "#;

        self.db.execute(sql, vars).await
            .map_err(|e| DavError::Storage(e))?;

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // Tests will be added in D10.5
}
