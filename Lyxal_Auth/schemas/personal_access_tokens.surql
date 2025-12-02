-- ============================================================
-- TABLE: personal_access_tokens
-- SOURCE: personal_access_tokens.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE personal_access_tokens TYPE NORMAL SCHEMAFULL
COMMENT "Tokens d'accès personnels (PAT)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE personal_access_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE personal_access_tokens 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS name ON TABLE personal_access_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS value ON TABLE personal_access_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE personal_access_tokens 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE personal_access_tokens 
    TYPE option<datetime>;

-- INDEX & CONTRAINTES

-- PK Composite (tenant_id, user_id, name)
DEFINE INDEX IF NOT EXISTS idx_pk_composite ON TABLE personal_access_tokens 
    FIELDS tenant_id, user_id, name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_value ON TABLE personal_access_tokens 
    FIELDS tenant_id, value;
