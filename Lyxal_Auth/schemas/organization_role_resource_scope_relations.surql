-- ============================================================
-- TABLE: organization_role_resource_scope_relations
-- SOURCE: organization_role_resource_scope_relations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_role_resource_scope_relations TYPE NORMAL SCHEMAFULL
COMMENT "Scopes de ressource assignés à un rôle d'organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_role_resource_scope_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_role_id ON TABLE organization_role_resource_scope_relations 
    TYPE string;
-- Reference organization_roles

DEFINE FIELD IF NOT EXISTS scope_id ON TABLE organization_role_resource_scope_relations 
    TYPE string;
-- Reference scopes

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_role_id, scope_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_role_resource_scope_relations 
    FIELDS tenant_id, organization_role_id, scope_id UNIQUE;
