-- ============================================================
-- TABLE: custom_profile_fields
-- SOURCE: custom_profile_fields.sql
-- ============================================================

DEFINE IF NOT EXISTS TABLE custom_profile_fields TYPE NORMAL SCHEMAFULL
COMMENT "Champs de profil personnalisés"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS tenant_id ON TABLE custom_profile_fields 
    TYPE string;

DEFINE FIELD IF NOT EXISTS id ON TABLE custom_profile_fields 
    TYPE string;

DEFINE FIELD IF NOT EXISTS name ON TABLE custom_profile_fields 
    TYPE string
    COMMENT "Nom technique du champ";

DEFINE FIELD IF NOT EXISTS type ON TABLE custom_profile_fields 
    TYPE string
    COMMENT "Type de champ (CustomProfileFieldType)";

DEFINE FIELD IF NOT EXISTS label ON TABLE custom_profile_fields 
    TYPE string
    DEFAULT '';

DEFINE FIELD IF NOT EXISTS description ON TABLE custom_profile_fields 
    TYPE option<string>;

DEFINE FIELD IF NOT EXISTS required ON TABLE custom_profile_fields 
    TYPE bool
    DEFAULT false;

DEFINE FIELD IF NOT EXISTS config ON TABLE custom_profile_fields 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration du champ";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE custom_profile_fields 
    TYPE datetime
    DEFAULT time::now();

DEFINE FIELD IF NOT EXISTS sie_order ON TABLE custom_profile_fields 
    TYPE int
    DEFAULT 0
    COMMENT "Ordre d'affichage (Géré par trigger en SQL)";

-- INDEX & CONTRAINTES

-- Unique (tenant_id, name)
DEFINE INDEX IF NOT EXISTS idx_unique_name ON TABLE custom_profile_fields 
    FIELDS tenant_id, name UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_id ON TABLE custom_profile_fields 
    FIELDS tenant_id, id;

-- Note: Trigger custom_profile_fields__increment_sie_order ignoré (voir conversion_notes.md)
