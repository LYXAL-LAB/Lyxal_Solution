-- ============================================================
-- TABLE: scopes
-- SOURCE: scopes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE scopes TYPE NORMAL SCHEMAFULL
COMMENT "Scopes (Permissions) liés à une ressource"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS resource_id ON TABLE scopes 
    TYPE string;
-- Reference resources

DEFINE FIELD IF NOT EXISTS name ON TABLE scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS description ON TABLE scopes 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE scopes 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- Unique (tenant_id, resource_id, name)
DEFINE INDEX IF NOT EXISTS idx_unique_scope ON TABLE scopes 
    FIELDS tenant_id, resource_id, name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE scopes 
    FIELDS tenant_id, id;
