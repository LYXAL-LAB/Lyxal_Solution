-- ============================================================
-- TABLE: sso_config (SSO ENTREPRISE)
-- Namespace: NS_ORG_{UUID} (Vault Org)
-- ============================================================

DEFINE IF NOT EXISTS TABLE sso_config TYPE NORMAL SCHEMAFULL
COMMENT "Configuration du SSO d'entreprise (Just-in-Time Provisioning)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS provider_name ON TABLE sso_config 
    TYPE string 
    COMMENT "Nom du provider (ex: Azure AD Corp)";

DEFINE FIELD IF NOT EXISTS type ON TABLE sso_config 
    TYPE string 
    ASSERT $value INSIDE ['oidc', 'saml']
    COMMENT "Protocole utilisé";

DEFINE FIELD IF NOT EXISTS domain ON TABLE sso_config 
    TYPE string 
    COMMENT "Domaine email auto-redirigé (ex: acme.com)";

DEFINE FIELD IF NOT EXISTS config ON TABLE sso_config 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration technique (Client ID, Certificats...)";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE sso_config 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_domain ON TABLE sso_config 
    FIELDS domain UNIQUE
    COMMENT "Un domaine ne peut être revendiqué que par un seul SSO";
