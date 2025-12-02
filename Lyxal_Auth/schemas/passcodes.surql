-- ============================================================
-- TABLE: passcodes
-- SOURCE: passcodes.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE passcodes TYPE NORMAL SCHEMAFULL
COMMENT "Codes de vérification (Email, SMS)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE passcodes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE passcodes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS interaction_jti ON TABLE passcodes 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS phone ON TABLE passcodes 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS email ON TABLE passcodes 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS type ON TABLE passcodes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS code ON TABLE passcodes 
    TYPE string;

DEFINE FIELD IF NOT EXISTS consumed ON TABLE passcodes 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS try_count ON TABLE passcodes 
    TYPE int
    DEFAULT 0;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE passcodes 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE passcodes 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_interaction_type ON TABLE passcodes 
    FIELDS tenant_id, interaction_jti, type;

DEFINE INDEX IF NOT EXISTS idx_email_type ON TABLE passcodes 
    FIELDS tenant_id, email, type;

DEFINE INDEX IF NOT EXISTS idx_phone_type ON TABLE passcodes 
    FIELDS tenant_id, phone, type;
