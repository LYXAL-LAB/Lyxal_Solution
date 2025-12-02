-- ============================================================
-- TABLE: organization_application_relations
-- SOURCE: organization_application_relations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_application_relations TYPE NORMAL SCHEMAFULL
COMMENT "Applications membres d'une organisation (Machine-to-Machine)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_application_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE organization_application_relations 
    TYPE string; 
-- Reference organizations (sera record<organizations>)

DEFINE FIELD IF NOT EXISTS application_id ON TABLE organization_application_relations 
    TYPE record<applications>;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_id, application_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_application_relations 
    FIELDS tenant_id, organization_id, application_id UNIQUE;

-- Note: Contrainte check_application_type ignorée (voir conversion_notes.md)
