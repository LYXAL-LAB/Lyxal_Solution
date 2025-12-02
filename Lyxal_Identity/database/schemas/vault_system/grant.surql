-- ============================================================
-- TABLE: grant (CONSENTEMENTS OAUTH)
-- Namespace: LYXAL_SYSTEM (Vault System)
-- ============================================================

DEFINE IF NOT EXISTS TABLE grant TYPE NORMAL SCHEMAFULL
COMMENT "Consentements donnés par les utilisateurs aux applications"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE grant 
    TYPE string 
    COMMENT "L'utilisateur qui a donné son accord";

DEFINE FIELD IF NOT EXISTS client_id ON TABLE grant 
    TYPE string 
    COMMENT "L'application autorisée";

DEFINE FIELD IF NOT EXISTS resource_id ON TABLE grant 
    TYPE string 
    COMMENT "La ressource concernée";

DEFINE FIELD IF NOT EXISTS scope ON TABLE grant 
    TYPE string 
    COMMENT "Le scope accordé (ex: read:profile)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE grant 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE grant 
    TYPE option<datetime>
    COMMENT "Expiration du consentement (si applicable)";

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_grant ON TABLE grant 
    FIELDS identity_id, client_id, resource_id, scope UNIQUE
    COMMENT "Un consentement est unique pour un tuple donné";
