-- ============================================================
-- TABLE: organization_jit_roles
-- SOURCE: organization_jit_roles.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_jit_roles TYPE NORMAL SCHEMAFULL
COMMENT "Rôles attribués automatiquement lors du provisionnement JIT"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_jit_roles 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE organization_jit_roles 
    TYPE string;
-- Reference organizations

DEFINE FIELD IF NOT EXISTS organization_role_id ON TABLE organization_jit_roles 
    TYPE string;
-- Reference organization_roles

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_id, organization_role_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_jit_roles 
    FIELDS tenant_id, organization_id, organization_role_id UNIQUE;
