-- ============================================================
-- TABLE: organization_roles
-- SOURCE: organization_roles.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_roles TYPE NORMAL SCHEMAFULL
COMMENT "Rôles définis au niveau de l'organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE organization_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE organization_roles 
    TYPE string
    COMMENT "Nom du rôle (unique par tenant)";

DEFINE FIELD IF NOT EXISTS description ON TABLE organization_roles 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS type ON TABLE organization_roles 
    TYPE string
    DEFAULT 'User'
    ASSERT $value INSIDE ['User', 'MachineToMachine']
    COMMENT "Type de rôle (User, MachineToMachine)";

-- INDEX & CONTRAINTES

-- Unique (tenant_id, name)
DEFINE INDEX IF NOT EXISTS idx_unique_name ON TABLE organization_roles 
    FIELDS tenant_id, name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE organization_roles 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_type ON TABLE organization_roles 
    FIELDS tenant_id, type;

-- Note: Fonction check_organization_role_type ignorée (voir conversion_notes.md)
