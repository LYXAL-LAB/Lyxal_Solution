-- ============================================================
-- TABLE: oidc_model_instances
-- SOURCE: oidc_model_instances.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE oidc_model_instances TYPE NORMAL SCHEMAFULL
COMMENT "Stockage générique pour les modèles OIDC (Grants, Codes, etc.)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE oidc_model_instances 
    TYPE string;

DEFINE FIELD IF NOT EXISTS model_name ON TABLE oidc_model_instances 
    TYPE string
    COMMENT "Nom du modèle (ex: AuthorizationCode, AccessToken)";

DEFINE FIELD IF NOT EXISTS id ON TABLE oidc_model_instances 
    TYPE string;

DEFINE FIELD IF NOT EXISTS payload ON TABLE oidc_model_instances 
    TYPE object
    COMMENT "Données du modèle OIDC";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE oidc_model_instances 
    TYPE datetime;

DEFINE FIELD IF NOT EXISTS consumed_at ON TABLE oidc_model_instances 
    TYPE option<datetime>;

-- INDEX & CONTRAINTES

-- Unique (tenant_id, model_name, id)
DEFINE INDEX IF NOT EXISTS idx_unique_model_id ON TABLE oidc_model_instances 
    FIELDS tenant_id, model_name, id UNIQUE;

-- Index JSON
DEFINE INDEX IF NOT EXISTS idx_user_code ON TABLE oidc_model_instances 
    FIELDS tenant_id, model_name, payload.userCode;

DEFINE INDEX IF NOT EXISTS idx_uid ON TABLE oidc_model_instances 
    FIELDS tenant_id, model_name, payload.uid;

DEFINE INDEX IF NOT EXISTS idx_grant_id ON TABLE oidc_model_instances 
    FIELDS tenant_id, model_name, payload.grantId;
