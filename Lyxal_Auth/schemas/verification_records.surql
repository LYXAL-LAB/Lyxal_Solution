-- ============================================================
-- TABLE: verification_records
-- SOURCE: verification_records.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE verification_records TYPE NORMAL SCHEMAFULL
COMMENT "Enregistrements de vérification"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE verification_records 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE verification_records 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE verification_records 
    TYPE option<string>;
-- Reference users

DEFINE FIELD IF NOT EXISTS created_at ON TABLE verification_records 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE verification_records 
    TYPE datetime;

DEFINE FIELD IF NOT EXISTS data ON TABLE verification_records 
    TYPE object
    DEFAULT {};

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE verification_records 
    FIELDS tenant_id, id;
