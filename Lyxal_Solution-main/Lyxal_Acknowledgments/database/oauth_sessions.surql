DEFINE TABLE IF NOT EXISTS oauth_sessions TYPE NORMAL SCHEMAFULL
    COMMENT "Stocke les refresh tokens OAuth chiffrés pour la gestion de session"
    PERMISSIONS FULL;

DEFINE FIELD IF NOT EXISTS session_id ON TABLE oauth_sessions 
    TYPE string
    COMMENT "Identifiant de session (lié au cookie)";

DEFINE FIELD IF NOT EXISTS user_sub ON TABLE oauth_sessions 
    TYPE string
    COMMENT "Identifiant utilisateur OAuth (sub claim)";

DEFINE FIELD IF NOT EXISTS refresh_token_encrypted ON TABLE oauth_sessions 
    TYPE string
    COMMENT "Refresh token chiffré (AES-256-GCM)";

DEFINE FIELD IF NOT EXISTS access_token_expires_at ON TABLE oauth_sessions 
    TYPE datetime
    COMMENT "Date d'expiration du token d'accès actuel";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE oauth_sessions 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Date de création de la session";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE oauth_sessions 
    TYPE datetime 
    DEFAULT time::now()
    COMMENT "Dernière mise à jour de la session";

DEFINE FIELD IF NOT EXISTS last_refreshed_at ON TABLE oauth_sessions 
    TYPE datetime
    COMMENT "Date du dernier rafraîchissement de token";

DEFINE FIELD IF NOT EXISTS user_agent ON TABLE oauth_sessions 
    TYPE string
    COMMENT "User Agent du navigateur (pour détection de vol de session)";

DEFINE FIELD IF NOT EXISTS ip_address ON TABLE oauth_sessions 
    TYPE string
    COMMENT "Adresse IP (pour détection de vol de session)";

DEFINE INDEX IF NOT EXISTS idx_oauth_sessions_session_id ON TABLE oauth_sessions 
    COLUMNS session_id UNIQUE
    COMMENT "Index unique sur l'ID de session";

DEFINE INDEX IF NOT EXISTS idx_oauth_sessions_user_sub ON TABLE oauth_sessions 
    COLUMNS user_sub
    COMMENT "Index par utilisateur";

DEFINE INDEX IF NOT EXISTS idx_oauth_sessions_expires_at ON TABLE oauth_sessions 
    COLUMNS access_token_expires_at
    COMMENT "Index pour le nettoyage des sessions expirées";
