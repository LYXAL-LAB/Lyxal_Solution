-- ============================================================
-- TABLE: organizations
-- SOURCE: organizations.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE organizations TYPE NORMAL SCHEMAFULL
COMMENT "Organisations (Groupes de tenants/utilisateurs)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE organizations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE organizations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE organizations 
    TYPE string;

DEFINE FIELD IF NOT EXISTS description ON TABLE organizations 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS custom_data ON TABLE organizations 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS is_mfa_required ON TABLE organizations 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS color ON TABLE organizations 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS branding ON TABLE organizations 
    TYPE object
    DEFAULT {};

DEFINE FIELD IF NOT EXISTS custom_css ON TABLE organizations 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE organizations 
    TYPE datetime
    DEFAULT time::now();

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE organizations 
    FIELDS tenant_id, id;
