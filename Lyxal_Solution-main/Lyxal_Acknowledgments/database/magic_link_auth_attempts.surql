DEFINE TABLE IF NOT EXISTS magic_link_auth_attempts TYPE NORMAL SCHEMAFULL
    COMMENT "Journal de sécurité des tentatives d'authentification par Magic Link"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS email ON TABLE magic_link_auth_attempts 
    TYPE string
    COMMENT "Email concerné par la tentative";

DEFINE FIELD IF NOT EXISTS success ON TABLE magic_link_auth_attempts 
    TYPE bool
    COMMENT "Succès ou échec de l'authentification";

DEFINE FIELD IF NOT EXISTS failure_reason ON TABLE magic_link_auth_attempts 
    TYPE string
    COMMENT "Raison de l'échec (ex: token expiré, invalide)";

DEFINE FIELD IF NOT EXISTS ip_address ON TABLE magic_link_auth_attempts 
    TYPE string
    COMMENT "Adresse IP de la tentative";

DEFINE FIELD IF NOT EXISTS user_agent ON TABLE magic_link_auth_attempts 
    TYPE string
    COMMENT "User Agent de la tentative";

DEFINE FIELD IF NOT EXISTS attempted_at ON TABLE magic_link_auth_attempts 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de la tentative";

DEFINE INDEX IF NOT EXISTS idx_magic_link_attempts_ip_time ON TABLE magic_link_auth_attempts 
    COLUMNS ip_address, attempted_at
    COMMENT "Index pour le rate limiting par IP";

DEFINE INDEX IF NOT EXISTS idx_magic_link_attempts_email_time ON TABLE magic_link_auth_attempts 
    COLUMNS email, attempted_at
    COMMENT "Index pour le rate limiting par email";
