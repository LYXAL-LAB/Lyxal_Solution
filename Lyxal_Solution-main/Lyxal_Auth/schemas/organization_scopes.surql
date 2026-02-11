-- ============================================================
-- TABLE: organization_scopes
-- SOURCE: organization_scopes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_scopes TYPE NORMAL SCHEMAFULL
COMMENT "Scopes (permissions) définis au niveau de l'organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE organization_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE organization_scopes 
    TYPE string
    COMMENT "Nom du scope (unique par tenant)";

DEFINE FIELD IF NOT EXISTS description ON TABLE organization_scopes 
    TYPE option<string>;

-- INDEX & CONTRAINTES

-- Unique (tenant_id, name)
DEFINE INDEX IF NOT EXISTS idx_unique_name ON TABLE organization_scopes 
    FIELDS tenant_id, name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE organization_scopes 
    FIELDS tenant_id, id;
