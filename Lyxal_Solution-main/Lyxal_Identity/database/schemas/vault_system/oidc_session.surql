-- ============================================================
-- TABLE: oidc_session (SESSIONS UTILISATEUR)
-- Namespace: LYXAL_SYSTEM (Vault System)
-- ============================================================

DEFINE IF NOT EXISTS TABLE oidc_session TYPE NORMAL SCHEMAFULL
COMMENT "Sessions actives des utilisateurs (Cookies, Tokens)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS uid ON TABLE oidc_session 
    TYPE string 
    COMMENT "ID unique de session (dans le cookie)";

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE oidc_session 
    TYPE string 
    COMMENT "L'utilisateur connecté (identity:...)";

DEFINE FIELD IF NOT EXISTS client_id ON TABLE oidc_session 
    TYPE string 
    COMMENT "L'application utilisée";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE oidc_session 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE oidc_session 
    TYPE datetime 
    COMMENT "Expiration de la session";

DEFINE FIELD IF NOT EXISTS user_agent ON TABLE oidc_session 
    TYPE option<string>
    COMMENT "Navigateur / OS";

DEFINE FIELD IF NOT EXISTS ip_address ON TABLE oidc_session 
    TYPE option<string>
    COMMENT "Adresse IP";

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_uid ON TABLE oidc_session 
    FIELDS uid UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_identity ON TABLE oidc_session 
    FIELDS identity_id;
