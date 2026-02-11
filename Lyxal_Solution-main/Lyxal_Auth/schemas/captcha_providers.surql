-- ============================================================
-- TABLE: captcha_providers
-- SOURCE: captcha_providers.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE captcha_providers TYPE NORMAL SCHEMAFULL
COMMENT "Configuration du fournisseur de Captcha"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE captcha_providers 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE captcha_providers 
    TYPE string;

DEFINE FIELD IF NOT EXISTS config ON TABLE captcha_providers 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration du provider (Clés API, etc.)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE captcha_providers 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE captcha_providers 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

-- Unique (tenant_id) -> Un seul provider actif/configuré par tenant ?
DEFINE INDEX IF NOT EXISTS idx_tenant_unique ON TABLE captcha_providers 
    FIELDS tenant_id UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE captcha_providers 
    FIELDS tenant_id, id;
