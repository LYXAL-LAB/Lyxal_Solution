--
-- Schéma pour les permissions disponibles dans le système
-- Définit les types d'accès possibles pour les routes
--

DEFINE TABLE route_permissions SCHEMAFULL;

-- Identité de la permission
DEFINE FIELD code ON route_permissions TYPE string
    ASSERT $value =~ "^[a-z_]+$" AND $value != "";
DEFINE FIELD name_i18n ON route_permissions TYPE string
    ASSERT $value != "";
DEFINE FIELD category ON route_permissions TYPE string
    ASSERT $value != "";

-- Métadonnées
DEFINE FIELD description_i18n ON route_permissions TYPE string;
DEFINE FIELD is_system ON route_permissions TYPE bool DEFAULT false;

-- Timestamps
DEFINE FIELD created_at ON route_permissions TYPE datetime
    DEFAULT time::now() READONLY;
DEFINE FIELD updated_at ON route_permissions TYPE datetime
    DEFAULT time::now() UPDATEONLY;

-- ETag pour optimistic locking
DEFINE FIELD etag ON route_permissions TYPE string
    DEFAULT rand::string(32);

-- Indexes
DEFINE INDEX idx_permission_code ON route_permissions FIELDS code UNIQUE;
DEFINE INDEX idx_permission_category ON route_permissions FIELDS category;
DEFINE INDEX idx_permission_system ON route_permissions FIELDS is_system;

-- Permissions d'accès
DEFINE ACCESS permission_admin ON route_permissions TYPE RECORD
    FOR select, create, update, delete
    WHERE $auth.role = "admin";

DEFINE ACCESS permission_read ON route_permissions TYPE RECORD
    FOR select
    WHERE true;
