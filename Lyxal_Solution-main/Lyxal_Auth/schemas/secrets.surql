-- ============================================================
-- TABLE: secrets
-- SOURCE: secrets.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE secrets TYPE NORMAL SCHEMAFULL
COMMENT "Secrets chiffrés (Tokens, Clés)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE secrets 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS type ON TABLE secrets 
    TYPE string;

DEFINE FIELD IF NOT EXISTS encrypted_dek ON TABLE secrets 
    TYPE string
    COMMENT "Data Encryption Key chiffrée (Bytes stockés en base64 ou hex)";

DEFINE FIELD IF NOT EXISTS iv ON TABLE secrets 
    TYPE string
    COMMENT "Initialization Vector";

DEFINE FIELD IF NOT EXISTS auth_tag ON TABLE secrets 
    TYPE string
    COMMENT "Authentication Tag";

DEFINE FIELD IF NOT EXISTS ciphertext ON TABLE secrets 
    TYPE string
    COMMENT "Données chiffrées";

DEFINE FIELD IF NOT EXISTS metadata ON TABLE secrets 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS created_at ON TABLE secrets 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE secrets 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE secrets 
    FIELDS tenant_id, id;

-- Note: Trigger set_updated_at ignoré (voir conversion_notes.md)
