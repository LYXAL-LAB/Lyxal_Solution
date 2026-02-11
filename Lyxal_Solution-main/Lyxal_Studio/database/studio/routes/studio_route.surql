--
-- Schéma principal pour les routes dynamiques
-- Définit la structure des routes stockées en base de données
--

DEFINE TABLE studio_route SCHEMAFULL;

-- Identité de la route
DEFINE FIELD identity ON studio_route TYPE object;
DEFINE FIELD identity.value ON studio_route TYPE string
    ASSERT $value =~ "^/" AND $value != "/" AND $value != "";
DEFINE FIELD identity.slug ON studio_route TYPE string
    ASSERT $value =~ "^[a-z0-9-]+$" AND $value != "";
DEFINE FIELD identity.code ON studio_route TYPE string
    ASSERT $value =~ "^[a-z_]+$" AND $value != "";

-- Référence vers la page associée (optionnelle pour développement)
DEFINE FIELD page ON studio_route TYPE option<record<studio_page>>;
DEFINE FIELD page.* ON studio_route;

-- Permissions requises pour accéder à la route
DEFINE FIELD permissions ON studio_route TYPE array<string>
    ASSERT array::len($value) > 0;
DEFINE FIELD permissions.* ON studio_route TYPE string
    ASSERT $value IN ["guest", "authenticated", "admin", "manager"];

-- Guards de sécurité optionnels
DEFINE FIELD guards ON studio_route TYPE array<object>;
DEFINE FIELD guards.*.type ON studio_route TYPE string
    ASSERT $value IN ["auth", "role", "subscription", "feature"];
DEFINE FIELD guards.*.condition ON studio_route TYPE object;

-- Métadonnées optionnelles
DEFINE FIELD metadata ON studio_route TYPE object;
DEFINE FIELD metadata.title_i18n ON studio_route TYPE string;
DEFINE FIELD metadata.description_i18n ON studio_route TYPE string;
DEFINE FIELD metadata.icon ON studio_route TYPE string;
DEFINE FIELD metadata.order ON studio_route TYPE int
    ASSERT $value >= 0;
DEFINE FIELD metadata.group ON studio_route TYPE string;
DEFINE FIELD metadata.tags ON studio_route TYPE array<string>;
DEFINE FIELD metadata.tags.* ON studio_route TYPE string;

-- Statut de la route
DEFINE FIELD status ON studio_route TYPE string
    ASSERT $value IN ["active", "inactive", "draft", "deprecated"];

-- Timestamps automatiques
DEFINE FIELD created_at ON studio_route TYPE datetime
    DEFAULT time::now() READONLY;
DEFINE FIELD updated_at ON studio_route TYPE datetime
    DEFAULT time::now() UPDATEONLY;

-- ETag pour optimistic locking
DEFINE FIELD etag ON studio_route TYPE string
    DEFAULT rand::string(32);

-- Indexes pour les performances
DEFINE INDEX idx_route_path ON studio_route FIELDS identity.value UNIQUE;
DEFINE INDEX idx_route_slug ON studio_route FIELDS identity.slug UNIQUE;
DEFINE INDEX idx_route_code ON studio_route FIELDS identity.code UNIQUE;
DEFINE INDEX idx_route_status ON studio_route FIELDS status;
DEFINE INDEX idx_route_permissions ON studio_route FIELDS permissions;
DEFINE INDEX idx_route_page ON studio_route FIELDS page;
DEFINE INDEX idx_route_active ON studio_route FIELDS status
    WHERE status = "active";

-- Permissions d'accès (seulement admin peut modifier)
DEFINE ACCESS route_admin ON studio_route TYPE RECORD
    FOR select, create, update, delete
    WHERE $auth.role = "admin";

DEFINE ACCESS route_read ON studio_route TYPE RECORD
    FOR select
    WHERE status = "active";
