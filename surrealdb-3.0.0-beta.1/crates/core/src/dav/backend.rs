//! DAV Backend Trait
//!
//! Abstract interface for DAV storage backends.
//! Implementations can use SurrealDB tables, SQLite, or other storage.

use async_trait::async_trait;
use std::collections::HashMap;

use super::error::DavError;
use super::types::{
    AddressBookQuery, CalendarQuery, Lock, Principal, Resource, ResourceKind, Share,
    SyncCollectionResult,
};

/// Interface for DAV storage backend
#[async_trait]
pub trait DavBackend: Send + Sync {
    // ═══════════════════════════════════════════════════════════════════
    // RESOURCE OPERATIONS
    // ═══════════════════════════════════════════════════════════════════

    /// Get a resource by path
    async fn get_resource(&self, path: &str) -> Result<Option<Resource>, DavError>;

    /// List children of a collection
    async fn list_collection(&self, path: &str) -> Result<Vec<Resource>, DavError>;

    /// Create or update a resource
    async fn put_resource(&self, path: &str, data: &[u8], mime: &str) -> Result<String, DavError>;

    /// Delete a resource
    async fn delete_resource(&self, path: &str) -> Result<(), DavError>;

    /// Create a collection (calendar, addressbook, or folder)
    async fn create_collection(&self, path: &str, kind: ResourceKind) -> Result<(), DavError>;

    /// Move a resource or collection
    async fn move_path(&self, src: &str, dst: &str, overwrite: bool) -> Result<(), DavError> {
        let _ = (src, dst, overwrite);
        Ok(())
    }

    /// Copy a resource or collection
    async fn copy_path(&self, src: &str, dst: &str, overwrite: bool) -> Result<(), DavError> {
        let _ = (src, dst, overwrite);
        Ok(())
    }

    // ═══════════════════════════════════════════════════════════════════
    // PROPERTY OPERATIONS
    // ═══════════════════════════════════════════════════════════════════

    /// Set custom DAV properties
    async fn set_properties(&self, path: &str, props: &[(String, String)]) -> Result<(), DavError> {
        let _ = (path, props);
        Ok(())
    }

    /// Remove custom DAV properties
    async fn remove_properties(&self, path: &str, names: &[String]) -> Result<(), DavError> {
        let _ = (path, names);
        Ok(())
    }

    /// Get custom DAV properties
    async fn get_properties(&self, path: &str) -> Result<HashMap<String, String>, DavError> {
        let _ = path;
        Ok(HashMap::new())
    }

    // ═══════════════════════════════════════════════════════════════════
    // AUTHENTICATION & PRINCIPALS
    // ═══════════════════════════════════════════════════════════════════

    /// Authenticate via Basic (user/pass)
    async fn authenticate_basic(
        &self,
        realm: Option<&str>,
        user: &str,
        pass: &str,
    ) -> Result<Option<Principal>, DavError> {
        let _ = (realm, user, pass);
        Ok(None)
    }

    /// Authenticate via Bearer token
    async fn authenticate_bearer(
        &self,
        realm: Option<&str>,
        token: &str,
    ) -> Result<Option<Principal>, DavError> {
        let _ = (realm, token);
        Ok(None)
    }

    /// Fetch a principal by username
    async fn get_principal(
        &self,
        realm: Option<&str>,
        user: &str,
    ) -> Result<Option<Principal>, DavError> {
        let _ = (realm, user);
        Ok(None)
    }

    /// List all principals in a realm
    async fn list_principals(&self, realm: Option<&str>) -> Result<Vec<Principal>, DavError> {
        let _ = realm;
        Ok(vec![])
    }

    /// Ensure a principal is recorded as owner of a calendar path
    async fn ensure_calendar_owner(
        &self,
        calendar_path: &str,
        principal: &str,
    ) -> Result<(), DavError> {
        let _ = (calendar_path, principal);
        Ok(())
    }

    // ═══════════════════════════════════════════════════════════════════
    // ACCESS CONTROL
    // ═══════════════════════════════════════════════════════════════════

    /// Check ACL for a principal on a path (write=false => read)
    async fn check_access(&self, principal: &str, path: &str, write: bool) -> Result<bool, DavError> {
        let _ = (principal, path, write);
        Ok(true)
    }

    // ═══════════════════════════════════════════════════════════════════
    // LOCKING
    // ═══════════════════════════════════════════════════════════════════

    /// Lock a resource
    async fn lock(
        &self,
        path: &str,
        token: &str,
        principal: Option<&str>,
        depth: &str,
        timeout: i64,
        owner_info: Option<&str>,
    ) -> Result<(), DavError> {
        let _ = (path, token, principal, depth, timeout, owner_info);
        Ok(())
    }

    /// Unlock a resource
    async fn unlock(&self, path: &str, token: &str) -> Result<(), DavError> {
        let _ = (path, token);
        Ok(())
    }

    /// Get locks for a resource
    async fn get_locks(&self, path: &str) -> Result<Vec<Lock>, DavError> {
        let _ = path;
        Ok(vec![])
    }

    // ═══════════════════════════════════════════════════════════════════
    // SYNC & QUERIES (CalDAV/CardDAV)
    // ═══════════════════════════════════════════════════════════════════

    /// REPORT sync-collection (incremental sync)
    async fn sync_collection(
        &self,
        path: &str,
        sync_token: Option<&str>,
        limit: Option<usize>,
    ) -> Result<SyncCollectionResult, DavError> {
        let token = sync_token.unwrap_or("1").to_string();
        let _ = (path, limit);
        Ok(SyncCollectionResult {
            resources: Vec::new(),
            sync_token: token,
            partial: false,
        })
    }

    /// Query a calendar collection (REPORT calendar-query)
    async fn query_collection(
        &self,
        path: &str,
        query: CalendarQuery,
    ) -> Result<Vec<Resource>, DavError> {
        let _ = query;
        self.list_collection(path).await
    }

    /// Generate FreeBusy response
    async fn free_busy_query(
        &self,
        path: &str,
        query: CalendarQuery,
    ) -> Result<Vec<Resource>, DavError> {
        let _ = query;
        self.list_collection(path).await
    }

    /// Query addressbook (REPORT addressbook-query)
    async fn query_addressbook(
        &self,
        path: &str,
        query: AddressBookQuery,
    ) -> Result<Vec<Resource>, DavError> {
        let _ = query;
        self.list_collection(path).await
    }

    // ═══════════════════════════════════════════════════════════════════
    // SHARING
    // ═══════════════════════════════════════════════════════════════════

    /// Get shares for a resource
    async fn get_shares(&self, path: &str) -> Result<Vec<Share>, DavError> {
        let _ = path;
        Ok(vec![])
    }

    /// Create a share
    async fn create_share(&self, share: &Share) -> Result<(), DavError> {
        let _ = share;
        Ok(())
    }

    /// Update share status
    async fn update_share_status(
        &self,
        path: &str,
        sharee: &str,
        accepted: bool,
    ) -> Result<(), DavError> {
        let _ = (path, sharee, accepted);
        Ok(())
    }

    /// Remove a share
    async fn remove_share(&self, path: &str, sharee: &str) -> Result<(), DavError> {
        let _ = (path, sharee);
        Ok(())
    }
}
