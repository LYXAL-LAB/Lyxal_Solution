-- ═══════════════════════════════════════════════════════════════════════════════
-- LYXAL DAV SCHEMA - Native SurrealDB Implementation
-- ═══════════════════════════════════════════════════════════════════════════════
-- Version: D10.1
-- Description: Complete DAV schema with collections, objects, locks, shares
-- Constraints: SCHEMAFULL, ASSERT, INDEX, EVENT for sync_token automation
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE: dav_collection
-- Description: Calendars, Addressbooks, Folders (WebDAV collections)
-- ═══════════════════════════════════════════════════════════════════════════════
DEFINE TABLE dav_collection SCHEMAFULL;

DEFINE FIELD realm ON dav_collection TYPE string ASSERT $value != NONE AND $value != "";
DEFINE FIELD path ON dav_collection TYPE string ASSERT $value != NONE AND $value != "";
DEFINE FIELD kind ON dav_collection TYPE string ASSERT $value IN ["collection", "calendar", "addressbook", "schedule-inbox", "schedule-outbox"];
DEFINE FIELD displayname ON dav_collection TYPE option<string>;
DEFINE FIELD description ON dav_collection TYPE option<string>;
DEFINE FIELD timezone ON dav_collection TYPE option<string>;
DEFINE FIELD color ON dav_collection TYPE option<string>;
DEFINE FIELD owner ON dav_collection TYPE string ASSERT $value != NONE;
DEFINE FIELD sync_token ON dav_collection TYPE int DEFAULT 1;
DEFINE FIELD deleted_at ON dav_collection TYPE option<datetime>;
DEFINE FIELD created_at ON dav_collection TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dav_collection TYPE datetime DEFAULT time::now();

-- Primary index: realm + path must be unique
DEFINE INDEX idx_dav_collection_realm_path ON dav_collection FIELDS realm, path UNIQUE;
-- Index for listing by owner
DEFINE INDEX idx_dav_collection_owner ON dav_collection FIELDS realm, owner;
-- Index for listing by kind
DEFINE INDEX idx_dav_collection_kind ON dav_collection FIELDS realm, kind;

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE: dav_object
-- Description: Calendar events (iCal), Contacts (vCard), Files
-- ═══════════════════════════════════════════════════════════════════════════════
DEFINE TABLE dav_object SCHEMAFULL;

DEFINE FIELD realm ON dav_object TYPE string ASSERT $value != NONE AND $value != "";
DEFINE FIELD path ON dav_object TYPE string ASSERT $value != NONE AND $value != "";
DEFINE FIELD collection_path ON dav_object TYPE string ASSERT $value != NONE;
DEFINE FIELD content ON dav_object TYPE bytes;
DEFINE FIELD etag ON dav_object TYPE string ASSERT $value != NONE;
DEFINE FIELD mime_type ON dav_object TYPE string DEFAULT "application/octet-stream";
DEFINE FIELD size ON dav_object TYPE int DEFAULT 0;
DEFINE FIELD uid ON dav_object TYPE option<string>;
DEFINE FIELD component_type ON dav_object TYPE option<string>;
DEFINE FIELD first_occurrence ON dav_object TYPE option<datetime>;
DEFINE FIELD last_occurrence ON dav_object TYPE option<datetime>;
DEFINE FIELD classification ON dav_object TYPE int DEFAULT 0;
DEFINE FIELD deleted_at ON dav_object TYPE option<datetime>;
DEFINE FIELD created_at ON dav_object TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dav_object TYPE datetime DEFAULT time::now();

-- Primary index: realm + path must be unique
DEFINE INDEX idx_dav_object_realm_path ON dav_object FIELDS realm, path UNIQUE;
-- Index for listing by collection
DEFINE INDEX idx_dav_object_collection ON dav_object FIELDS realm, collection_path;
-- Index for UID deduplication
DEFINE INDEX idx_dav_object_uid ON dav_object FIELDS realm, collection_path, uid;
-- Index for time-range queries
DEFINE INDEX idx_dav_object_occurrence ON dav_object FIELDS realm, collection_path, first_occurrence, last_occurrence;

-- EVENT: Auto-increment parent collection sync_token and log change
DEFINE EVENT dav_object_created ON TABLE dav_object WHEN $event = "CREATE" THEN {
    UPDATE dav_collection SET 
        sync_token = sync_token + 1, 
        updated_at = time::now() 
    WHERE realm = $after.realm AND path = $after.collection_path;
    
    CREATE dav_change_log SET
        realm = $after.realm,
        collection_path = $after.collection_path,
        object_path = $after.path,
        sync_token = (SELECT VALUE sync_token FROM dav_collection WHERE realm = $after.realm AND path = $after.collection_path)[0],
        operation = 1,
        created_at = time::now();
};

DEFINE EVENT dav_object_updated ON TABLE dav_object WHEN $event = "UPDATE" THEN {
    UPDATE dav_collection SET 
        sync_token = sync_token + 1, 
        updated_at = time::now() 
    WHERE realm = $after.realm AND path = $after.collection_path;
    
    CREATE dav_change_log SET
        realm = $after.realm,
        collection_path = $after.collection_path,
        object_path = $after.path,
        sync_token = (SELECT VALUE sync_token FROM dav_collection WHERE realm = $after.realm AND path = $after.collection_path)[0],
        operation = 2,
        created_at = time::now();
};

DEFINE EVENT dav_object_deleted ON TABLE dav_object WHEN $event = "DELETE" THEN {
    UPDATE dav_collection SET 
        sync_token = sync_token + 1, 
        updated_at = time::now() 
    WHERE realm = $before.realm AND path = $before.collection_path;
    
    CREATE dav_change_log SET
        realm = $before.realm,
        collection_path = $before.collection_path,
        object_path = $before.path,
        sync_token = (SELECT VALUE sync_token FROM dav_collection WHERE realm = $before.realm AND path = $before.collection_path)[0],
        operation = 3,
        created_at = time::now();
};

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE: dav_change_log
-- Description: Change tracking for sync-collection REPORT (RFC 6578)
-- operation: 1=CREATE, 2=UPDATE, 3=DELETE
-- ═══════════════════════════════════════════════════════════════════════════════
DEFINE TABLE dav_change_log SCHEMAFULL;

DEFINE FIELD realm ON dav_change_log TYPE string ASSERT $value != NONE;
DEFINE FIELD collection_path ON dav_change_log TYPE string ASSERT $value != NONE;
DEFINE FIELD object_path ON dav_change_log TYPE string ASSERT $value != NONE;
DEFINE FIELD sync_token ON dav_change_log TYPE int ASSERT $value != NONE;
DEFINE FIELD operation ON dav_change_log TYPE int ASSERT $value IN [1, 2, 3];
DEFINE FIELD created_at ON dav_change_log TYPE datetime DEFAULT time::now();

-- Index for sync-collection queries
DEFINE INDEX idx_dav_change_log_sync ON dav_change_log FIELDS realm, collection_path, sync_token;

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE: dav_lock
-- Description: WebDAV locks (RFC 4918)
-- ═══════════════════════════════════════════════════════════════════════════════
DEFINE TABLE dav_lock SCHEMAFULL;

DEFINE FIELD realm ON dav_lock TYPE string ASSERT $value != NONE;
DEFINE FIELD path ON dav_lock TYPE string ASSERT $value != NONE;
DEFINE FIELD token ON dav_lock TYPE string ASSERT $value != NONE;
DEFINE FIELD principal ON dav_lock TYPE option<string>;
DEFINE FIELD depth ON dav_lock TYPE string DEFAULT "0";
DEFINE FIELD timeout ON dav_lock TYPE int DEFAULT 3600;
DEFINE FIELD expires_at ON dav_lock TYPE datetime ASSERT $value != NONE;
DEFINE FIELD owner_info ON dav_lock TYPE option<string>;
DEFINE FIELD created_at ON dav_lock TYPE datetime DEFAULT time::now();

-- Token must be unique globally
DEFINE INDEX idx_dav_lock_token ON dav_lock FIELDS token UNIQUE;
-- Index for path lookup
DEFINE INDEX idx_dav_lock_realm_path ON dav_lock FIELDS realm, path;

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE: dav_prop
-- Description: Custom WebDAV properties (dead properties)
-- ═══════════════════════════════════════════════════════════════════════════════
DEFINE TABLE dav_prop SCHEMAFULL;

DEFINE FIELD realm ON dav_prop TYPE string ASSERT $value != NONE;
DEFINE FIELD path ON dav_prop TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON dav_prop TYPE string ASSERT $value != NONE;
DEFINE FIELD value ON dav_prop TYPE string;
DEFINE FIELD created_at ON dav_prop TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dav_prop TYPE datetime DEFAULT time::now();

-- Each property is unique per resource
DEFINE INDEX idx_dav_prop_unique ON dav_prop FIELDS realm, path, name UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE: dav_share
-- Description: Calendar/Addressbook sharing (RFC 5545-BIS, CalDAV Sharing)
-- access: 1=READ, 2=READ-WRITE, 3=ADMIN
-- status: 1=PENDING, 2=ACCEPTED, 3=DECLINED
-- ═══════════════════════════════════════════════════════════════════════════════
DEFINE TABLE dav_share SCHEMAFULL;

DEFINE FIELD realm ON dav_share TYPE string ASSERT $value != NONE;
DEFINE FIELD resource_path ON dav_share TYPE string ASSERT $value != NONE;
DEFINE FIELD owner ON dav_share TYPE string ASSERT $value != NONE;
DEFINE FIELD sharee ON dav_share TYPE string ASSERT $value != NONE;
DEFINE FIELD access ON dav_share TYPE int ASSERT $value IN [1, 2, 3] DEFAULT 1;
DEFINE FIELD status ON dav_share TYPE int ASSERT $value IN [1, 2, 3] DEFAULT 1;
DEFINE FIELD created_at ON dav_share TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dav_share TYPE datetime DEFAULT time::now();

-- Unique share per resource/sharee
DEFINE INDEX idx_dav_share_unique ON dav_share FIELDS realm, resource_path, sharee UNIQUE;
-- Index for sharee lookup (what's shared with me)
DEFINE INDEX idx_dav_share_sharee ON dav_share FIELDS realm, sharee;
-- Index for owner lookup (what I'm sharing)
DEFINE INDEX idx_dav_share_owner ON dav_share FIELDS realm, owner;
