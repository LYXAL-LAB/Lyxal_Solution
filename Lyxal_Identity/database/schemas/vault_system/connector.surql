-- ============================================================
-- TABLE: connector (SOCIAL LOGIN SYSTEM)
-- Namespace: LYXAL_SYSTEM (Vault System)
-- ============================================================

DEFINE IF NOT EXISTS TABLE connector TYPE NORMAL SCHEMAFULL
COMMENT "Configuration globale des connecteurs sociaux (Google, GitHub...)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS provider ON TABLE connector 
    TYPE string 
    COMMENT "Identifiant du provider (ex: google, github, apple)";

DEFINE FIELD IF NOT EXISTS config ON TABLE connector 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration technique sensible (Client ID, Client Secret chiffré)";

DEFINE FIELD IF NOT EXISTS metadata ON TABLE connector 
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées publiques (Logo, Nom affiché)";

DEFINE FIELD IF NOT EXISTS sync_profile ON TABLE connector 
    TYPE bool 
    DEFAULT true
    COMMENT "Si on synchronise le profil utilisateur à chaque connexion";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE connector 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE connector 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_provider ON TABLE connector 
    FIELDS provider UNIQUE;
