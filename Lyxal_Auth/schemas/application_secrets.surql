-- ============================================================
-- TABLE: application_secrets
-- SOURCE: application_secrets.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE application_secrets TYPE NORMAL SCHEMAFULL
COMMENT "Secrets des applications pour le grant type client_credentials"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE application_secrets 
    TYPE string
    COMMENT "ID du tenant";

DEFINE FIELD IF NOT EXISTS application_id ON TABLE application_secrets 
    TYPE record<applications>
    COMMENT "L'application associée";

DEFINE FIELD IF NOT EXISTS name ON TABLE application_secrets 
    TYPE string
    COMMENT "Nom du secret (doit être unique par application)";

DEFINE FIELD IF NOT EXISTS value ON TABLE application_secrets 
    TYPE string
    COMMENT "Valeur du secret (Hashé)";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE application_secrets 
    TYPE datetime
    DEFAULT time::now()
    COMMENT "Date de création";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE application_secrets 
    TYPE option<datetime>
    COMMENT "Date d'expiration";

-- INDEX & CONTRAINTES

-- Primary Key Composite (tenant_id, application_id, name)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE application_secrets 
    FIELDS tenant_id, application_id, name UNIQUE
    COMMENT "Unicité du nom de secret par application";