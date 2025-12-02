-- ============================================================
-- TABLE: sso_connector (SSO ENTREPRISE ORG)
-- Namespace: NS_ORG_{UUID} (Vault Org)
-- ============================================================

DEFINE IF NOT EXISTS TABLE sso_connector TYPE NORMAL SCHEMAFULL
COMMENT "Connecteurs SSO Enterprise spécifiques à une organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS provider_name ON TABLE sso_connector 
    TYPE string 
    COMMENT "Nom interne du provider (ex: AzureAD-Acme)";

DEFINE FIELD IF NOT EXISTS config ON TABLE sso_connector 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration technique (Endpoint, Certificat, Client Secret)";

DEFINE FIELD IF NOT EXISTS domains ON TABLE sso_connector 
    TYPE array
    DEFAULT []
    COMMENT "Liste des domaines email déclenchant ce connecteur";

DEFINE FIELD IF NOT EXISTS branding ON TABLE sso_connector 
    TYPE object
    DEFAULT {}
    COMMENT "Personnalisation du bouton de connexion";

DEFINE FIELD IF NOT EXISTS status ON TABLE sso_connector 
    TYPE string 
    DEFAULT 'active'
    ASSERT $value INSIDE ['active', 'inactive']
    COMMENT "État du connecteur";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE sso_connector 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE sso_connector 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
