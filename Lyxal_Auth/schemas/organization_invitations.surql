-- ============================================================
-- TABLE: organization_invitations
-- SOURCE: organization_invitations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organization_invitations TYPE NORMAL SCHEMAFULL
COMMENT "Invitations à rejoindre une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organization_invitations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE organization_invitations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS inviter_id ON TABLE organization_invitations 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS invitee ON TABLE organization_invitations 
    TYPE string
    COMMENT "Email ou identifiant de l'invité";

DEFINE FIELD IF NOT EXISTS accepted_user_id ON TABLE organization_invitations 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS organization_id ON TABLE organization_invitations 
    TYPE string;
-- Reference organizations

DEFINE FIELD IF NOT EXISTS status ON TABLE organization_invitations 
    TYPE string
    ASSERT $value INSIDE ['Pending', 'Accepted', 'Expired', 'Revoked'];

DEFINE FIELD IF NOT EXISTS created_at ON TABLE organization_invitations 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE organization_invitations 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE organization_invitations 
    TYPE datetime;

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE organization_invitations 
    FIELDS tenant_id, id;

-- Unique partiel (tenant_id, invitee, organization_id) WHERE status = 'Pending'
-- SurrealDB ne supporte pas nativement les index partiels WHERE.
-- On indexe sans contrainte unique stricte au niveau DB, ou on gère l'unicité logiciellement.
DEFINE INDEX IF NOT EXISTS idx_pending_invitation ON TABLE organization_invitations 
    FIELDS tenant_id, invitee, organization_id;
