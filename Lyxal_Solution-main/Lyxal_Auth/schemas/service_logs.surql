-- ============================================================
-- TABLE: service_logs
-- SOURCE: service_logs.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE service_logs TYPE NORMAL SCHEMAFULL
COMMENT "Logs de service internes"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS id ON TABLE service_logs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE service_logs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS type ON TABLE service_logs 
    TYPE string;

DEFINE FIELD IF NOT EXISTS payload ON TABLE service_logs 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS created_at ON TABLE service_logs 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE service_logs 
    FIELDS id;

DEFINE INDEX IF NOT EXISTS idx_tenant_type ON TABLE service_logs 
    FIELDS tenant_id, type;
