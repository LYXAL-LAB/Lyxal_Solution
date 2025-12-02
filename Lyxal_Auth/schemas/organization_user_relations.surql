-- ============================================================
-- TABLE: organization_user_relations
-- SOURCE: organization_user_relations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_user_relations TYPE NORMAL SCHEMAFULL
COMMENT "Membres (utilisateurs) d'une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_user_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE organization_user_relations 
    TYPE string;
-- Reference organizations

DEFINE FIELD IF NOT EXISTS user_id ON TABLE organization_user_relations 
    TYPE string;
-- Reference users

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_id, user_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_user_relations 
    FIELDS tenant_id, organization_id, user_id UNIQUE;
