-- ============================================================
-- TABLE: users
-- SOURCE: users.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE users TYPE NORMAL SCHEMAFULL
COMMENT "Utilisateurs (Entité principale)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE users 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE users 
    TYPE string;

DEFINE FIELD IF NOT EXISTS username ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS primary_email ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS primary_phone ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS password_encrypted ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS password_encryption_method ON TABLE users 
    TYPE option<string>
    ASSERT $value == NONE OR $value INSIDE ['Argon2i', 'Argon2id', 'Argon2d', 'SHA1', 'SHA256', 'MD5', 'Bcrypt', 'Legacy'];

DEFINE FIELD IF NOT EXISTS name ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS avatar ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS profile ON TABLE users 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS application_id ON TABLE users 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS identities ON TABLE users 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS custom_data ON TABLE users 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS logto_config ON TABLE users 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS mfa_verifications ON TABLE users 
    TYPE array
    DEFAULT [];

DEFINE FIELD IF NOT EXISTS is_suspended ON TABLE users 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS last_sign_in_at ON TABLE users 
    TYPE option<datetime>;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE users 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE users 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE users 
    FIELDS tenant_id, id UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_username ON TABLE users 
    FIELDS tenant_id, username UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_primary_email ON TABLE users 
    FIELDS tenant_id, primary_email UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_primary_phone ON TABLE users 
    FIELDS tenant_id, primary_phone UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_name ON TABLE users 
    FIELDS tenant_id, name;

-- Note: Trigger set_updated_at ignoré (voir conversion_notes.md)
