-- ============================================================================
-- FONCTIONS : réglages des langues de l'installation
-- MODULE    : lyxal_i18n
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::i18n_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_settings_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $settings = (SELECT default_locale.tag AS default_locale, source_locale.tag AS source_locale FROM ONLY i18n_settings:installation);
    RETURN fn::result_ok($settings);
} COMMENT "Réglages des langues de l'installation : { default_locale, source_locale } (étiquettes)";

-- ----------------------------------------------------------------------------
-- fn::i18n_settings_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_settings_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            default_locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
            source_locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "i18n.locale.manage" }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { permission: "i18n.locale.manage" });
    };
    FOR $tag IN array::filter([$p.default_locale, $p.source_locale], |$t| $t IS NOT NONE) {
        LET $locale = (SELECT active FROM ONLY type::record("i18n_locale", $tag));
        IF $locale == NONE { RETURN fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $tag }); };
        IF !$locale.active { RETURN fn::error_result("I18N_LOCALE_INACTIVE", $p.language, { locale: $tag }); };
    };
    LET $current = (SELECT default_locale, source_locale FROM ONLY i18n_settings:installation);
    LET $updated = (UPDATE ONLY i18n_settings:installation SET
        default_locale = IF $p.default_locale IS NONE { $current.default_locale } ELSE { type::record("i18n_locale", $p.default_locale) },
        source_locale = IF $p.source_locale IS NONE { $current.source_locale } ELSE { type::record("i18n_locale", $p.source_locale) });
    IF $updated == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_settings" });
    };
    RETURN fn::result_ok({ default_locale: $updated.default_locale.tag, source_locale: $updated.source_locale.tag });
} COMMENT "Modifie les réglages des langues ({ default_locale, source_locale }) ; langue inconnue (I18N_LOCALE_NOT_FOUND) ou inactive (I18N_LOCALE_INACTIVE) refusée. Permission i18n.locale.manage";
