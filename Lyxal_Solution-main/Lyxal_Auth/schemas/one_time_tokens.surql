-- ============================================================
-- TABLE: one_time_tokens
-- SOURCE: one_time_tokens.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE one_time_tokens TYPE NORMAL SCHEMAFULL
COMMENT "Tokens à usage unique (Magic Links, Reset Password)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE one_time_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE one_time_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS email ON TABLE one_time_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS token ON TABLE one_time_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS context ON TABLE one_time_tokens 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS status ON TABLE one_time_tokens 
    TYPE string
    DEFAULT 'active';

DEFINE FIELD IF NOT EXISTS created_at ON TABLE one_time_tokens 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE one_time_tokens 
    TYPE datetime;

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_email_status ON TABLE one_time_tokens 
    FIELDS tenant_id, email, status;

-- Unique (tenant_id, token)
DEFINE INDEX IF NOT EXISTS idx_unique_token ON TABLE one_time_tokens 
    FIELDS tenant_id, token UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE one_time_tokens 
    FIELDS tenant_id, id;
