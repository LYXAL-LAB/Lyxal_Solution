-- =============================================================================
-- MODULE: BASE SOUS MODULE : USER
-- TABLE: base_user_role (UserRole)
-- Rôles d'autorisation dans le système
-- =============================================================================
DEFINE TABLE IF NOT EXISTS base_user_role TYPE NORMAL SCHEMAFULL
COMMENT "Rôles d'autorisation dans le système"
PERMISSIONS FULL;

-- Identification
DEFINE FIELD name ON base_user_role TYPE string
COMMENT "Nom du rôle";
DEFINE FIELD description ON base_user_role TYPE option<string>
COMMENT "Description du rôle";

-- Permissions associées
DEFINE FIELD permissions ON base_user_role TYPE array<record<base_user_permission>>
COMMENT "Permissions associées au rôle";

-- Index
DEFINE INDEX idx_role_name ON base_user_role FIELDS name UNIQUE;
