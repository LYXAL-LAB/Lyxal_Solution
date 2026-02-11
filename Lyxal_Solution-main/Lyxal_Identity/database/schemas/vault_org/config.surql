-- ============================================================
-- TABLE: config (CONFIGURATION ORG)
-- Namespace: NS_ORG_{UUID} (Vault Org)
-- ============================================================

DEFINE IF NOT EXISTS TABLE config TYPE NORMAL SCHEMAFULL
COMMENT "Configuration générale de l'organisation"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS name ON TABLE config 
    TYPE string 
    COMMENT "Nom de l'organisation";

DEFINE FIELD IF NOT EXISTS description ON TABLE config 
    TYPE option<string>
    COMMENT "Description";

DEFINE FIELD IF NOT EXISTS branding ON TABLE config 
    TYPE object
    DEFAULT {}
    COMMENT "Personnalisation (Logo, Couleurs)";

DEFINE FIELD IF NOT EXISTS custom_data ON TABLE config 
    TYPE object
    DEFAULT {}
    COMMENT "Données libres";

DEFINE FIELD IF NOT EXISTS is_mfa_required ON TABLE config 
    TYPE bool 
    DEFAULT false
    COMMENT "Si le MFA est obligatoire pour tous les membres";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE config 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
