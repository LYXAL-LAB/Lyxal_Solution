-- =============================================================================
-- MODULE: BASE SOUS MODULE : USER
-- TABLE: base_user_group (UserGroup)
-- Groupes d'utilisateurs
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_user_group TYPE NORMAL SCHEMAFULL
COMMENT "Groupes d'utilisateurs"
PERMISSIONS FULL;

-- Identification
DEFINE FIELD name ON base_user_group TYPE string
COMMENT "Nom du groupe";
DEFINE FIELD description ON base_user_group TYPE option<string>
COMMENT "Description du groupe";

-- Rôles associés
DEFINE FIELD roles ON base_user_group TYPE array<record<base_user_role>>
COMMENT "Rôles associés au groupe";

-- Index
DEFINE INDEX idx_user_group_name ON base_user_group FIELDS name UNIQUE; 