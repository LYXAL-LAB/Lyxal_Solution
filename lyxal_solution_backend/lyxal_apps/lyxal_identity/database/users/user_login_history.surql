---- Table de l'historique de connexion (ceci doit être une option pour éviter tracking des utilisateurs) ----

DEFINE TABLE IF NOT EXISTS user_login_history 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Historique de connexion de l'utilisateur";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS user ON TABLE user_login_history 
    TYPE record<users>
    REFERENCE ON DELETE CASCADE
    COMMENT "Utilisateur";

DEFINE FIELD IF NOT EXISTS application ON TABLE user_login_history 
    TYPE record<application>
    REFERENCE ON DELETE CASCADE
    COMMENT "Application";

DEFINE FIELD IF NOT EXISTS application_lyxal_identity ON TABLE user_login_history 
    TYPE record<lyxal_identity>
    REFERENCE ON DELETE CASCADE
    COMMENT "Application lyxal_identity";

DEFINE FIELD IF NOT EXISTS user_agent ON TABLE user_login_history 
    TYPE string
    COMMENT "User agent de l'utilisateur";

DEFINE FIELD IF NOT EXISTS login_time ON TABLE user_login_history 
    TYPE datetime 
    VALUE time::now()
    COMMENT "Date et heure de connexion";

DEFINE FIELD IF NOT EXISTS location ON TABLE user_login_history 
    TYPE option<point>
    ASSERT $value IS NONE OR geo::is_point($value)
    COMMENT "Dernières coordonnées GPS connues (Geo-velocity check)";

DEFINE FIELD IF NOT EXISTS last_ip ON TABLE user_login_history 
    TYPE option<string>
    ASSERT $value IS NONE OR string::is_ip($value)
    COMMENT "Dernière adresse IP connue";