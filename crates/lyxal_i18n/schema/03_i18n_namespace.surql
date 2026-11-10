-- ============================================================================
-- TABLE  : i18n_namespace
-- MODULE : lyxal_i18n
-- RÔLE   : Espaces de noms des clés de traduction (un par module propriétaire)
-- ============================================================================
-- Modèle : namespaces de Tolgee, components de Weblate. Identifiant = clé (i18n_namespace:base).

DEFINE TABLE OVERWRITE i18n_namespace
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, update WHERE fn::auth_has_permission({ permission: "i18n.translation.manage" })
        FOR delete NONE
    COMMENT "Espaces de noms des clés de traduction";

DEFINE FIELD OVERWRITE key ON TABLE i18n_namespace
    TYPE string
    READONLY
    ASSERT fn::validation_snake_case_name($value, 1, 64).value == $value
    COMMENT "Clé de l'espace de noms (snake_case), premier segment des clés complètes";

DEFINE FIELD OVERWRITE module ON TABLE i18n_namespace
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Module propriétaire des textes";

DEFINE FIELD OVERWRITE description ON TABLE i18n_namespace
    TYPE option<string>
    ASSERT $value IS NONE OR string::len($value) <= 1024
    COMMENT "Description libre";

DEFINE FIELD OVERWRITE source_locale ON TABLE i18n_namespace
    TYPE record<i18n_locale>
    READONLY
    COMMENT "Langue des textes sources de l'espace de noms";

DEFINE FIELD OVERWRITE created_at ON TABLE i18n_namespace
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Date de création";

DEFINE FIELD OVERWRITE updated_at ON TABLE i18n_namespace
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de dernière modification";

DEFINE INDEX OVERWRITE i18n_namespace_source_locale ON TABLE i18n_namespace FIELDS source_locale;
