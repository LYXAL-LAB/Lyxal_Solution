-- ============================================================
-- TABLE: account_centers
-- SOURCE: account_centers.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE account_centers TYPE NORMAL SCHEMAFULL
COMMENT "Configuration du portail utilisateur (Account Center)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE account_centers 
    TYPE string
    COMMENT "ID du tenant";

DEFINE FIELD IF NOT EXISTS id ON TABLE account_centers 
    TYPE string
    COMMENT "ID de la configuration (souvent unique par tenant)";

DEFINE FIELD IF NOT EXISTS enabled ON TABLE account_centers 
    TYPE bool
    DEFAULT true
    COMMENT "Si le portail est activé";

DEFINE FIELD IF NOT EXISTS fields ON TABLE account_centers 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration des champs modifiables (AccountCenterFieldControl)";

DEFINE FIELD IF NOT EXISTS webauthn_related_origins ON TABLE account_centers 
    TYPE array
    DEFAULT []
    COMMENT "Origines autorisées pour WebAuthn";

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, id)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE account_centers 
    FIELDS tenant_id, id UNIQUE;
