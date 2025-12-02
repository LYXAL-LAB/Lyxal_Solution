-- ============================================================
-- TABLE: one_time_token (TOKENS MAGIQUES)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE one_time_token TYPE NORMAL SCHEMAFULL
COMMENT "Tokens pour Magic Links et Reset Password"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS token_hash ON TABLE one_time_token 
    TYPE string 
    COMMENT "Hash du token (pour ne pas stocker le token brut)";

DEFINE FIELD IF NOT EXISTS type ON TABLE one_time_token 
    TYPE string 
    ASSERT $value INSIDE ['password_reset', 'magic_link', 'email_verification']
    COMMENT "Type d'action";

DEFINE FIELD IF NOT EXISTS context ON TABLE one_time_token 
    TYPE object
    DEFAULT {}
    COMMENT "Données contextuelles (ex: redirect_uri)";

DEFINE FIELD IF NOT EXISTS used ON TABLE one_time_token 
    TYPE bool 
    DEFAULT false
    COMMENT "Si le token a déjà été consommé";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE one_time_token 
    TYPE datetime 
    COMMENT "Date d'expiration";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE one_time_token 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
