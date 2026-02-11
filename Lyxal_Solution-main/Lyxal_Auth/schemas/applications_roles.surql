-- ============================================================
-- TABLE: applications_roles
-- SOURCE: applications_roles.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE applications_roles TYPE NORMAL SCHEMAFULL
COMMENT "Association entre Applications et Rôles (MachineToMachine)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE applications_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE applications_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS application_id ON TABLE applications_roles 
    TYPE record<applications>;

DEFINE FIELD IF NOT EXISTS role_id ON TABLE applications_roles 
    TYPE record<roles>; 
-- Note: La table roles sera créée plus tard.

-- INDEX & CONTRAINTES

-- Unique (tenant_id, application_id, role_id)
DEFINE INDEX IF NOT EXISTS idx_unique_app_role ON TABLE applications_roles 
    FIELDS tenant_id, application_id, role_id UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE applications_roles 
    FIELDS tenant_id, id;

-- Note: Contrainte check_role_type ignorée (voir conversion_notes.md)
