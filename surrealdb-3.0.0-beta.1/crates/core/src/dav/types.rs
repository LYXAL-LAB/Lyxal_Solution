//! DAV Types
//!
//! Core type definitions for WebDAV/CalDAV/CardDAV operations.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Represents a DAV resource (calendar, object, collection, contact)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Resource {
    pub path: String,
    pub kind: ResourceKind,
    pub mime_type: String,
    pub etag: String,
    pub content: Option<Vec<u8>>,
    pub properties: HashMap<String, String>,
    pub sync_token: Option<String>,
}

/// Type of DAV resource
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum ResourceKind {
    Collection,
    Calendar,
    Object,
    Principal,
    ScheduleInbox,
    ScheduleOutbox,
    AddressBook,
    Contact,
    Generic,
}

/// Result of a REPORT sync-collection
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SyncCollectionResult {
    pub resources: Vec<Resource>,
    pub sync_token: String,
    pub partial: bool,
}

/// DAV Principal (authenticated user)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Principal {
    pub username: String,
    pub displayname: String,
    pub email: Option<String>,
    pub calendar_home: String,
    pub addressbook_home: Option<String>,
    pub principal_url: String,
    pub schedule_inbox_url: Option<String>,
    pub schedule_outbox_url: Option<String>,
    pub alternate_uris: Vec<String>,
    pub realm_id: Option<String>,
}

/// DAV Lock
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Lock {
    pub path: String,
    pub token: String,
    pub principal: Option<String>,
    pub depth: String,
    pub timeout: i64,
    pub expires_at: i64,
    pub owner_info: Option<String>,
}

/// Calendar query parameters
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CalendarQuery {
    pub start: Option<String>,
    pub end: Option<String>,
}

/// AddressBook query parameters
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AddressBookQuery {
    pub filter: Filter,
}

/// Filter for queries
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Filter {
    pub prop_filters: Vec<PropFilter>,
}

/// Property filter
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PropFilter {
    pub name: String,
    pub text_match: Option<TextMatch>,
    pub is_not_defined: bool,
}

/// Text match criteria
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextMatch {
    pub value: String,
    pub negate_condition: bool,
    pub collation: String,
    pub match_type: String,
}

/// Scheduling message for CalDAV
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchedulingMessage {
    pub path: String,
    pub principal: String,
    pub box_type: String,
    pub content: String,
    pub etag: String,
    pub created_at: String,
}

/// Share for CalDAV/CardDAV sharing
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Share {
    pub resource_path: String,
    pub owner: String,
    pub sharee: String,
    pub access_level: ShareAccess,
    pub status: ShareStatus,
}

/// Share access level
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum ShareAccess {
    Read,
    ReadWrite,
    Admin,
}

/// Share status
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum ShareStatus {
    Pending,
    Accepted,
    Declined,
}

/// DAV Response for HTTP layer
#[derive(Debug, Clone)]
pub struct DavResponse {
    pub status: u16,
    pub headers: HashMap<String, String>,
    pub body: Vec<u8>,
}

impl DavResponse {
    pub fn empty(status: u16) -> Self {
        Self {
            status,
            headers: HashMap::new(),
            body: Vec::new(),
        }
    }

    pub fn xml(status: u16, xml: String) -> Self {
        let mut headers = HashMap::new();
        headers.insert(
            "Content-Type".to_string(),
            "application/xml; charset=utf-8".to_string(),
        );
        Self {
            status,
            headers,
            body: xml.into_bytes(),
        }
    }

    pub fn ics(status: u16, ics: String, etag: Option<String>) -> Self {
        let mut headers = HashMap::new();
        headers.insert(
            "Content-Type".to_string(),
            "text/calendar; charset=utf-8".to_string(),
        );
        if let Some(tag) = etag {
            headers.insert("ETag".to_string(), format!("\"{}\"", tag));
        }
        Self {
            status,
            headers,
            body: ics.into_bytes(),
        }
    }

    pub fn vcard(status: u16, vcard: String, etag: Option<String>) -> Self {
        let mut headers = HashMap::new();
        headers.insert(
            "Content-Type".to_string(),
            "text/vcard; charset=utf-8".to_string(),
        );
        if let Some(tag) = etag {
            headers.insert("ETag".to_string(), format!("\"{}\"", tag));
        }
        Self {
            status,
            headers,
            body: vcard.into_bytes(),
        }
    }
}
