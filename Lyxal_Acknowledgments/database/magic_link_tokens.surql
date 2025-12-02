DEFINE TABLE IF NOT EXISTS magic_link_tokens TYPE NORMAL SCHEMAFULL
    COMMENT "Tokens pour l'authentification sans mot de passe (Magic Link)"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS token ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "Token sécurisé unique";

DEFINE FIELD IF NOT EXISTS email ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "Email de l'utilisateur associé";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE magic_link_tokens 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de génération du token";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE magic_link_tokens 
    TYPE datetime
    COMMENT "Date d'expiration du token";

DEFINE FIELD IF NOT EXISTS used_at ON TABLE magic_link_tokens 
    TYPE datetime
    COMMENT "Date d'utilisation (NULL si non utilisé)";

DEFINE FIELD IF NOT EXISTS used_by_ip ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "Adresse IP ayant utilisé le token";

DEFINE FIELD IF NOT EXISTS used_by_user_agent ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "User Agent ayant utilisé le token";

DEFINE FIELD IF NOT EXISTS redirect_to ON TABLE magic_link_tokens 
    TYPE string 
    DEFAULT '/'
    COMMENT "URL de redirection après succès";

DEFINE FIELD IF NOT EXISTS created_by_ip ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "Adresse IP ayant demandé le token";

DEFINE FIELD IF NOT EXISTS created_by_user_agent ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "User Agent ayant demandé le token";

DEFINE FIELD IF NOT EXISTS purpose ON TABLE magic_link_tokens 
    TYPE string 
    DEFAULT 'login'
    COMMENT "But du token : 'login' (15min) ou 'reminder_auth' (24h)";

DEFINE FIELD IF NOT EXISTS doc_id ON TABLE magic_link_tokens 
    TYPE string
    COMMENT "ID du document lié (si purpose = reminder_auth)";

DEFINE INDEX IF NOT EXISTS idx_magic_link_tokens_token ON TABLE magic_link_tokens 
    COLUMNS token UNIQUE
    COMMENT "Index unique sur le token";

DEFINE INDEX IF NOT EXISTS idx_magic_link_tokens_email ON TABLE magic_link_tokens 
    COLUMNS email
    COMMENT "Index par email";

DEFINE INDEX IF NOT EXISTS idx_magic_link_tokens_expires ON TABLE magic_link_tokens 
    COLUMNS expires_at
    COMMENT "Index pour le nettoyage des tokens expirés";

DEFINE INDEX IF NOT EXISTS idx_magic_link_tokens_purpose ON TABLE magic_link_tokens 
    COLUMNS purpose
    COMMENT "Index par type d'usage";

DEFINE INDEX IF NOT EXISTS idx_magic_link_tokens_doc_id ON TABLE magic_link_tokens 
    COLUMNS doc_id
    COMMENT "Index par document lié";
