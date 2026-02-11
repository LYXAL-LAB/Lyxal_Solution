-- ============================================================
-- TABLE: verification_statuses
-- SOURCE: verification_statuses.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE verification_statuses TYPE NORMAL SCHEMAFULL
COMMENT "Statuts de vérification des utilisateurs"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE verification_statuses 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE verification_statuses 
    TYPE string;

DEFINE FIELD IF NOT EXISTS user_id ON TABLE verification_statuses 
    TYPE string;
-- Reference users

DEFINE FIELD IF NOT EXISTS created_at ON TABLE verification_statuses 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS verified_identifier ON TABLE verification_statuses 
    TYPE option<string>;

-- INDEX & CONTRAINTES

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE verification_statuses 
    FIELDS tenant_id, id;

DEFINE INDEX IF NOT EXISTS idx_user_id ON TABLE verification_statuses 
    FIELDS tenant_id, user_id;
