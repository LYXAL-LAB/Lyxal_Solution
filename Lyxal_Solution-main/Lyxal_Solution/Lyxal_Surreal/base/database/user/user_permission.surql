-- =============================================================================
-- MODULE: BASE SOUS MODULE : USER
-- TABLE: base_user_permission (UserPermission)
-- Permissions granulaires du système
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_user_permission TYPE NORMAL SCHEMAFULL
COMMENT "Permissions granulaires du système"
PERMISSIONS FULL;

-- Identification
DEFINE FIELD name ON base_user_permission TYPE string
COMMENT "Nom de la permission";
DEFINE FIELD object ON base_user_permission TYPE option<string>
COMMENT "Objet de la permission";
DEFINE FIELD canRead ON base_user_permission TYPE bool DEFAULT false
COMMENT "Peut lire";
DEFINE FIELD canWrite ON base_user_permission TYPE bool DEFAULT false
COMMENT "Peut écrire";
DEFINE FIELD canCreate ON base_user_permission TYPE bool DEFAULT false
COMMENT "Peut créer";
DEFINE FIELD canRemove ON base_user_permission TYPE bool DEFAULT false
COMMENT "Peut supprimer";
DEFINE FIELD canExport ON base_user_permission TYPE bool DEFAULT false
COMMENT "Peut exporter";

-- Index
DEFINE INDEX idx_user_permission_name ON base_user_permission FIELDS name;
DEFINE INDEX idx_user_permission_object ON base_user_permission FIELDS object;
