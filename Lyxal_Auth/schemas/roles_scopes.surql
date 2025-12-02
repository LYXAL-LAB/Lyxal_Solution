-- ============================================================
-- TABLE: roles_scopes
-- SOURCE: roles_scopes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE roles_scopes TYPE NORMAL SCHEMAFULL
COMMENT "Association Rôles - Scopes"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE roles_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE roles_scopes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS role_id ON TABLE roles_scopes 
    TYPE string;
-- Reference roles

DEFINE FIELD IF NOT EXISTS scope_id ON TABLE roles_scopes 
    TYPE string;
-- Reference scopes

-- INDEX & CONTRAINTES

-- Unique (tenant_id, role_id, scope_id)
DEFINE INDEX IF NOT EXISTS idx_unique_role_scope ON TABLE roles_scopes 
    FIELDS tenant_id, role_id, scope_id UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE roles_scopes 
    FIELDS tenant_id, id;
