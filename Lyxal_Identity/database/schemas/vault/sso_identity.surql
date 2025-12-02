-- ============================================================
-- TABLE: sso_identity (ENTREPRISE SSO)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE sso_identity TYPE NORMAL SCHEMAFULL
COMMENT "Identités SSO Enterprise liées (Azure AD, Okta, Google Workspace, etc.)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS issuer ON TABLE sso_identity 
    TYPE string
    COMMENT "Émetteur SSO (ex: https://login.microsoftonline.com/tenant-id)";

DEFINE FIELD IF NOT EXISTS sub ON TABLE sso_identity 
    TYPE string
    COMMENT "ID de l'utilisateur chez le provider (subject claim)";

DEFINE FIELD IF NOT EXISTS profile ON TABLE sso_identity 
    TYPE object
    DEFAULT {}
    COMMENT "Profil caché récupéré du provider SSO";

DEFINE FIELD IF NOT EXISTS sso_connector_id ON TABLE sso_identity 
    TYPE option<string>
    COMMENT "Référence au connecteur SSO configuré (optionnel)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE sso_identity 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE sso_identity 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_issuer_sub ON TABLE sso_identity 
    FIELDS issuer, sub UNIQUE
    COMMENT "Un utilisateur ne peut lier qu'une seule fois un compte SSO provider";
