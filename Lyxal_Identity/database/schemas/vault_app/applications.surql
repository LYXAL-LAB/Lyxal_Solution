-- ============================================================
-- TABLE: applications (CONFIGURATION APP)
-- Namespace: NS_APP_{UUID} (Vault App)
-- ============================================================

DEFINE IF NOT EXISTS TABLE applications TYPE NORMAL SCHEMAFULL
COMMENT "Configuration principale de l'application"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS name ON TABLE applications 
    TYPE string 
    COMMENT "Nom de l'application";

DEFINE FIELD IF NOT EXISTS secret ON TABLE applications 
    TYPE string 
    DEFAULT ''
    COMMENT "Secret interne (Deprecated - utiliser la table secret)";

DEFINE FIELD IF NOT EXISTS description ON TABLE applications 
    TYPE option<string>
    COMMENT "Description";

DEFINE FIELD IF NOT EXISTS type ON TABLE applications 
    TYPE string 
    ASSERT $value INSIDE ['Native', 'SPA', 'Traditional', 'MachineToMachine', 'Protected', 'SAML']
    COMMENT "Type d'application";

DEFINE FIELD IF NOT EXISTS oidc_client_metadata ON TABLE applications 
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées OIDC (redirect_uris, scopes, etc.)";

DEFINE FIELD IF NOT EXISTS custom_client_metadata ON TABLE applications 
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées client personnalisées";

DEFINE FIELD IF NOT EXISTS protected_app_metadata ON TABLE applications 
    TYPE option<object>
    COMMENT "Métadonnées pour les apps protégées (Host, Custom Domains)";

DEFINE FIELD IF NOT EXISTS custom_data ON TABLE applications 
    TYPE object
    DEFAULT {}
    COMMENT "Données libres";

DEFINE FIELD IF NOT EXISTS is_third_party ON TABLE applications 
    TYPE bool 
    DEFAULT false
    COMMENT "Si c'est une application tierce";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE applications 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_type ON TABLE applications 
    FIELDS type;

DEFINE INDEX IF NOT EXISTS idx_is_third_party ON TABLE applications 
    FIELDS is_third_party;
