-- ============================================================
-- TABLE: daily_token_usage
-- SOURCE: daily_token_usage.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE daily_token_usage TYPE NORMAL SCHEMAFULL
COMMENT "Statistiques d'usage des tokens par jour"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS id ON TABLE daily_token_usage 
    TYPE string;

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE daily_token_usage 
    TYPE string;

DEFINE FIELD IF NOT EXISTS usage ON TABLE daily_token_usage 
    TYPE int
    DEFAULT 0;

DEFINE FIELD IF NOT EXISTS date ON TABLE daily_token_usage 
    TYPE datetime;

-- INDEX & CONTRAINTES

-- Unique (tenant_id, date) -> Une entrée par jour par tenant
DEFINE INDEX IF NOT EXISTS idx_unique_date ON TABLE daily_token_usage 
    FIELDS tenant_id, date UNIQUE;
