-- ============================================================
-- TABLE: connectors
-- SOURCE: connectors.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE connectors TYPE NORMAL SCHEMAFULL
COMMENT "Connecteurs sociaux et autres (Google, GitHub...)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE connectors 
    TYPE string;

DEFINE FIELD IF NOT EXISTS sync_profile ON TABLE connectors 
    TYPE bool
    DEFAULT false
    COMMENT "Synchroniser le profil utilisateur à la connexion";

DEFINE FIELD IF NOT EXISTS enable_token_storage ON TABLE connectors 
    TYPE bool
    DEFAULT false
    COMMENT "Stocker les tokens (OAuth2/OIDC)";

DEFINE FIELD IF NOT EXISTS connector_id ON TABLE connectors 
    TYPE string
    COMMENT "Identifiant du type de connecteur (ex: google)";

DEFINE FIELD IF NOT EXISTS config ON TABLE connectors 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration technique (Client ID, Secret...)";

DEFINE FIELD IF NOT EXISTS metadata ON TABLE connectors 
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées (Logo, Nom...)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE connectors 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE connectors 
    FIELDS tenant_id, id;
