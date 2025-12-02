-- ============================================================
-- TABLE: organization_invitation_role_relations
-- SOURCE: organization_invitation_role_relations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_invitation_role_relations TYPE NORMAL SCHEMAFULL
COMMENT "Rôles d'organisation assignés à une invitation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_invitation_role_relations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS organization_invitation_id ON TABLE organization_invitation_role_relations 
    TYPE string;
-- Reference organization_invitations (sera record<organization_invitations>)

DEFINE FIELD IF NOT EXISTS organization_role_id ON TABLE organization_invitation_role_relations 
    TYPE string;
-- Reference organization_roles (sera record<organization_roles>)

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, organization_invitation_id, organization_role_id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE organization_invitation_role_relations 
    FIELDS tenant_id, organization_invitation_id, organization_role_id UNIQUE;
