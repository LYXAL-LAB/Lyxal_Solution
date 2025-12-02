-- ============================================================
-- TABLE: roles
-- SOURCE: roles.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE roles TYPE NORMAL SCHEMAFULL
COMMENT "Rôles globaux (User, MachineToMachine)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS description ON TABLE roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS type ON TABLE roles 
    TYPE string
    DEFAULT 'User'
    ASSERT $value INSIDE ['User', 'MachineToMachine'];

DEFINE FIELD IF NOT EXISTS is_default ON TABLE roles 
    TYPE bool
    DEFAULT false;

-- INDEX & CONTRAINTES

-- Unique (tenant_id, name)
DEFINE INDEX IF NOT EXISTS idx_unique_name ON TABLE roles 
    FIELDS tenant_id, name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE roles 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_type ON TABLE roles 
    FIELDS tenant_id, type;

-- Note: Fonction check_role_type ignorée (voir conversion_notes.md)
