-- ============================================================
-- TABLE: activity (HISTORIQUE D'ACTIVITÉ)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE activity TYPE NORMAL SCHEMAFULL
COMMENT "Historique d'activité de l'utilisateur"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS last_sign_in_at ON TABLE activity 
    TYPE option<datetime>
    COMMENT "Date de dernière connexion";

DEFINE FIELD IF NOT EXISTS last_sign_in_ip ON TABLE activity 
    TYPE option<string>
    COMMENT "IP de dernière connexion";

DEFINE FIELD IF NOT EXISTS last_sign_in_user_agent ON TABLE activity 
    TYPE option<string>
    COMMENT "User-Agent de dernière connexion";

DEFINE FIELD IF NOT EXISTS sign_in_count ON TABLE activity 
    TYPE int
    DEFAULT 0
    COMMENT "Nombre total de connexions";

DEFINE FIELD IF NOT EXISTS account_created_at ON TABLE activity 
    TYPE datetime 
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création du compte";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE activity 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
