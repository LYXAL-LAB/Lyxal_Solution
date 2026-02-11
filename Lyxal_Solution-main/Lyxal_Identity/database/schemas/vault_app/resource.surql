-- ============================================================
-- TABLE: resource (API RESSOURCES)
-- Namespace: NS_APP_{UUID} (Vault App)
-- ============================================================

DEFINE IF NOT EXISTS TABLE resource TYPE NORMAL SCHEMAFULL
COMMENT "Ressources API protégées (Resource Server)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS indicator ON TABLE resource 
    TYPE string 
    COMMENT "Identifiant unique de la ressource (URI, ex: https://api.mysaas.com)";

DEFINE FIELD IF NOT EXISTS name ON TABLE resource 
    TYPE string 
    COMMENT "Nom convivial";

DEFINE FIELD IF NOT EXISTS is_default ON TABLE resource 
    TYPE bool 
    DEFAULT false
    COMMENT "Si c'est l'API par défaut pour les tokens";

DEFINE FIELD IF NOT EXISTS access_token_ttl ON TABLE resource 
    TYPE int 
    DEFAULT 3600
    COMMENT "Durée de vie des tokens pour cette ressource (secondes)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE resource 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_indicator ON TABLE resource 
    FIELDS indicator UNIQUE;
