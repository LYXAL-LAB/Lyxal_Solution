-- ============================================================
-- TABLE: users_roles
-- SOURCE: users_roles.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE users_roles TYPE NORMAL SCHEMAFULL
COMMENT "Rôles assignés aux utilisateurs"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE users_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE users_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE users_roles 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS role_id ON TABLE users_roles 
    TYPE string;
-- Reference roles

-- INDEX & CONTRAINTES

-- Unique (tenant_id, user_id, role_id)
DEFINE INDEX IF NOT EXISTS idx_unique_user_role ON TABLE users_roles 
    FIELDS tenant_id, user_id, role_id UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE users_roles 
    FIELDS tenant_id, id;

-- Note: Contrainte check_role_type ignorée (voir conversion_notes.md)
