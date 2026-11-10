-- ============================================================================
-- FONCTIONS : référentiel des langues
-- MODULE    : lyxal_i18n
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            active: { pipeline: [{ rule: "boolean" }] },
            search: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- optional_string a déjà nettoyé la recherche (blanc → NONE)
    LET $search = fn::sanitize_lowercase($p.search);
    LET $rows = (SELECT * FROM i18n_locale
        WHERE ($p.active IS NONE OR active = $p.active)
            AND ($search IS NONE OR string::starts_with(string::lowercase(tag), $search)
                OR string::contains(string::lowercase(name_en), $search)
                OR string::contains(string::lowercase(name_native), $search))
        ORDER BY tag);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Liste les langues du référentiel ({ active, search, limit, start }) : recherche sur le début de l'étiquette ou dans les noms, triées par étiquette ; { items, total }";

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $found = (SELECT * FROM ONLY type::record("i18n_locale", $p.locale));
    IF $found == NONE {
        RETURN fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $p.locale });
    };
    RETURN fn::result_ok($found);
} COMMENT "Lit une langue du référentiel ({ locale }, étiquette BCP 47 mise sous forme canonique)";

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_set_active (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_set_active($params: object, $active: bool) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
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
    LET $id = type::record("i18n_locale", $p.locale);
    IF !record::exists($id) {
        RETURN fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $p.locale });
    };
    IF !$active {
        LET $settings = (SELECT default_locale, source_locale FROM ONLY i18n_settings:installation);
        IF $settings.default_locale = $id OR $settings.source_locale = $id
            OR array::len(SELECT VALUE id FROM i18n_namespace WHERE source_locale = $id LIMIT 1) > 0 {
            RETURN fn::error_result("I18N_LOCALE_DEFAULT_REQUIRED", $p.language, { locale: $p.locale });
        };
    };
    LET $updated = (UPDATE ONLY $id SET active = $active);
    IF $updated == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_locale" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Interne : active ou désactive une langue ({ locale }) pour fn::i18n_locale_activate et fn::i18n_locale_deactivate";

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_activate
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_activate($params: object) {
    RETURN fn::i18n_locale_set_active($params, true);
} COMMENT "Active une langue du référentiel ({ locale }) ; publie i18n.locale.activated. Permission i18n.locale.manage";

-- ----------------------------------------------------------------------------
-- fn::i18n_locale_deactivate
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_locale_deactivate($params: object) {
    RETURN fn::i18n_locale_set_active($params, false);
} COMMENT "Désactive une langue ({ locale }), sauf la langue par défaut, la langue source ou celle d'un espace de noms (I18N_LOCALE_DEFAULT_REQUIRED) ; publie i18n.locale.deactivated. Permission i18n.locale.manage";
