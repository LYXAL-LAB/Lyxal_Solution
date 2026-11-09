-- ============================================================================
-- TABLE  : i18n_settings
-- MODULE : lyxal_i18n
-- RÔLE   : Réglages des langues de l'installation (enregistrement i18n_settings:installation)
-- ============================================================================

DEFINE TABLE OVERWRITE i18n_settings
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create, delete NONE
        FOR update WHERE fn::auth_has_permission({ permission: "i18n.locale.manage" })
    COMMENT "Réglages des langues de l'installation";

DEFINE FIELD OVERWRITE default_locale ON TABLE i18n_settings
    TYPE record<i18n_locale>
    ASSERT $value.active = true
    COMMENT "Langue par défaut de l'installation (active)";

DEFINE FIELD OVERWRITE source_locale ON TABLE i18n_settings
    TYPE record<i18n_locale>
    ASSERT $value.active = true
    COMMENT "Langue des textes sources des clés de traduction (active)";

DEFINE FIELD OVERWRITE updated_at ON TABLE i18n_settings
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";
