-- lyxal-test: assertions
-- Réglages des langues de l'installation et permission déclarée auprès de lyxal_auth.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["i18n.locale.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: identités et sessions
{
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@lyxal.test" } };
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: permission i18n.locale.manage déclarée et accordée à l'administrateur de la plateforme
RETURN (SELECT VALUE scope FROM ONLY auth_permission:⟨i18n.locale.manage⟩) == "installation"
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:platform_admin) CONTAINS "i18n.locale.manage";

-- test: réglages initiaux lisibles par tous
-- en tant que: membre
RETURN fn::i18n_settings_get({}).data == { default_locale: "fr", source_locale: "fr" };

-- test: un membre ne modifie pas les réglages
-- en tant que: membre
RETURN fn::i18n_settings_update({ default_locale: "en" }).error.code == "I18N_PERMISSION_DENIED";

-- test: langue inactive ou inconnue refusée, paramètre inconnu refusé
-- en tant que: plateforme
RETURN fn::i18n_settings_update({ default_locale: "de" }).error.code == "I18N_LOCALE_INACTIVE"
    AND fn::i18n_settings_update({ source_locale: "tlh" }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_settings_update({ default: "en" }).error.code == "I18N_INVALID_PARAMETERS";

-- test: l'administrateur change la langue par défaut ; la langue source est conservée
-- en tant que: plateforme
RETURN fn::i18n_settings_update({ default_locale: "EN" }).data == { default_locale: "en", source_locale: "fr" }
    AND fn::i18n_settings_get({}).data.default_locale == "en";

-- test: l'ancienne langue par défaut reste la langue source et ne se désactive pas
-- en tant que: plateforme
RETURN fn::i18n_locale_deactivate({ locale: "fr" }).error.code == "I18N_LOCALE_DEFAULT_REQUIRED";
