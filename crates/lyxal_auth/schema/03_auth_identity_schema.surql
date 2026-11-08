-- ============================================================================
-- TABLE  : auth_identity_schema
-- MODULE : lyxal_auth
-- RÔLE   : Définition des traits d'une identité (schéma du moteur lyxal_core)
-- ============================================================================
-- Modèle : schémas d'identité Kratos, User Profile Keycloak. `traits` est un schéma
-- `fn::validation_object_execute` ({ fields, unknown_keys }) appliqué aux traits de chaque
-- identité ; `identifiers` désigne les traits servant d'identifiant de connexion.

DEFINE TABLE OVERWRITE auth_identity_schema
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update WHERE fn::auth_has_permission({ permission: "auth.identity.manage" })
        FOR delete NONE
    COMMENT "Schémas des traits d'identité (versionnés)";

DEFINE FIELD OVERWRITE key ON TABLE auth_identity_schema
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    READONLY
    COMMENT "Clé du schéma (ex. default)";

DEFINE FIELD OVERWRITE version ON TABLE auth_identity_schema
    TYPE int
    ASSERT $value >= 1
    READONLY
    COMMENT "Version du schéma (une nouvelle version par modification)";

DEFINE FIELD OVERWRITE traits ON TABLE auth_identity_schema
    TYPE object
    READONLY
    COMMENT "Schéma du moteur lyxal_core appliqué aux traits";

DEFINE FIELD OVERWRITE traits.* ON TABLE auth_identity_schema
    TYPE any;

DEFINE FIELD OVERWRITE identifiers ON TABLE auth_identity_schema
    TYPE array<object>
    DEFAULT []
    READONLY
    COMMENT "Traits identifiants de connexion : [{ trait, type }] (type : email, username, phone)";

DEFINE FIELD OVERWRITE identifiers.* ON TABLE auth_identity_schema
    TYPE object;

DEFINE FIELD OVERWRITE identifiers.*.trait ON TABLE auth_identity_schema
    TYPE string;

DEFINE FIELD OVERWRITE identifiers.*.type ON TABLE auth_identity_schema
    TYPE string
    ASSERT $value IN ["email", "username", "phone"];

DEFINE FIELD OVERWRITE verifiable ON TABLE auth_identity_schema
    TYPE array<object>
    DEFAULT []
    READONLY
    COMMENT "Traits à vérifier ou servant à la récupération : [{ trait, channel, usage }]";

DEFINE FIELD OVERWRITE verifiable.* ON TABLE auth_identity_schema
    TYPE object;

DEFINE FIELD OVERWRITE verifiable.*.trait ON TABLE auth_identity_schema
    TYPE string;

DEFINE FIELD OVERWRITE verifiable.*.channel ON TABLE auth_identity_schema
    TYPE string
    ASSERT $value IN ["email", "phone"];

DEFINE FIELD OVERWRITE verifiable.*.usage ON TABLE auth_identity_schema
    TYPE string
    ASSERT $value IN ["verification", "recovery"];

DEFINE FIELD OVERWRITE is_default ON TABLE auth_identity_schema
    TYPE bool
    DEFAULT false
    COMMENT "Schéma appliqué par défaut aux nouvelles identités (un seul)";

DEFINE FIELD OVERWRITE created_at ON TABLE auth_identity_schema
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE INDEX OVERWRITE auth_identity_schema_key_version ON TABLE auth_identity_schema FIELDS key, version UNIQUE;
DEFINE INDEX OVERWRITE auth_identity_schema_default ON TABLE auth_identity_schema FIELDS is_default;
