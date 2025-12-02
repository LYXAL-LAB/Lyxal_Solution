--
-- Schéma pour les guards de sécurité disponibles
-- Définit les mécanismes de protection des routes
--

DEFINE TABLE route_guards SCHEMAFULL;

-- Identité du guard
DEFINE FIELD code ON route_guards TYPE string
    ASSERT $value =~ "^[a-z_]+$" AND $value != "";
DEFINE FIELD name_i18n ON route_guards TYPE string
    ASSERT $value != "";
DEFINE FIELD type ON route_guards TYPE string
    ASSERT $value IN ["auth", "role", "subscription", "feature"];

-- Configuration et métadonnées
DEFINE FIELD description_i18n ON route_guards TYPE string;
DEFINE FIELD config_schema ON route_guards TYPE object;
DEFINE FIELD is_system ON route_guards TYPE bool DEFAULT false;

-- Timestamps
DEFINE FIELD created_at ON route_guards TYPE datetime
    DEFAULT time::now() READONLY;
DEFINE FIELD updated_at ON route_guards TYPE datetime
    DEFAULT time::now() UPDATEONLY;

-- ETag pour optimistic locking
DEFINE FIELD etag ON route_guards TYPE string
    DEFAULT rand::string(32);

-- Indexes
DEFINE INDEX idx_guard_code ON route_guards FIELDS code UNIQUE;
DEFINE INDEX idx_guard_type ON route_guards FIELDS type;
DEFINE INDEX idx_guard_system ON route_guards FIELDS is_system;

-- Permissions d'accès
DEFINE ACCESS guard_admin ON route_guards TYPE RECORD
    FOR select, create, update, delete
    WHERE $auth.role = "admin";

DEFINE ACCESS guard_read ON route_guards TYPE RECORD
    FOR select
    WHERE true;
