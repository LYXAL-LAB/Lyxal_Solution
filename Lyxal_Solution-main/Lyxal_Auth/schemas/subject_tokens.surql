-- ============================================================
-- TABLE: subject_tokens
-- SOURCE: subject_tokens.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE subject_tokens TYPE NORMAL SCHEMAFULL
COMMENT "Tokens de sujet (Échange de token)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE subject_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE subject_tokens 
    TYPE string;

DEFINE FIELD IF NOT EXISTS context ON TABLE subject_tokens 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE subject_tokens 
    TYPE datetime;

DEFINE FIELD IF NOT EXISTS consumed_at ON TABLE subject_tokens 
    TYPE option<datetime>;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE subject_tokens 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS created_at ON TABLE subject_tokens 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS creator_id ON TABLE subject_tokens 
    TYPE string;

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE subject_tokens 
    FIELDS tenant_id, id;
