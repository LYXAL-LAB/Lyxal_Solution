-- ============================================================================
-- FONCTIONS : espaces de noms et clés de traduction
-- MODULE    : lyxal_i18n
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::i18n_namespace_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_namespace_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            module: { pipeline: [{ rule: "lyxal_module_name", options: { min_length: 1, max_length: 64 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            source_locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "i18n.translation.manage" }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { permission: "i18n.translation.manage" });
    };
    LET $id = type::record("i18n_namespace", $p.key);
    IF record::exists($id) {
        RETURN fn::error_result("I18N_NAMESPACE_EXISTS", $p.language, { namespace: $p.key });
    };
    LET $source = IF $p.source_locale IS NONE {
        (SELECT VALUE source_locale FROM ONLY i18n_settings:installation)
    } ELSE { type::record("i18n_locale", $p.source_locale) };
    LET $locale = (SELECT active FROM ONLY $source);
    IF $locale == NONE { RETURN fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $p.source_locale }); };
    IF !$locale.active { RETURN fn::error_result("I18N_LOCALE_INACTIVE", $p.language, { locale: $p.source_locale }); };
    LET $created = (CREATE ONLY $id CONTENT { key: $p.key, module: $p.module, description: $p.description, source_locale: $source });
    IF $created == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_namespace" });
    };
    RETURN fn::result_ok($created);
} COMMENT "Crée un espace de noms ({ key, module, description, source_locale }) ; langue source active, par défaut celle des réglages. Permission i18n.translation.manage";

-- ----------------------------------------------------------------------------
-- fn::i18n_namespace_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_namespace_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
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
    LET $rows = (SELECT * FROM i18n_namespace ORDER BY key);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Liste les espaces de noms ({ limit, start }), triés par clé ; { items, total }";

-- ----------------------------------------------------------------------------
-- fn::i18n_key_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_key_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            namespace: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "max_length", options: { max_length: 128 } }, { rule: "lyxal_event_name", options: { min_segments: 1, max_segments: 8 } }], required: true },
            source_text: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 10000 } }], required: true },
            syntax: { pipeline: [{ rule: "enum", options: { allowed: ["icu_mf1", "plain"], case_sensitive: true } }], default: "icu_mf1" },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            params: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    name: { pipeline: [{ rule: "identifier", options: { min_length: 1, max_length: 64 } }], required: true },
                    type: { pipeline: [{ rule: "enum", options: { allowed: ["string", "number", "datetime"], case_sensitive: true } }], required: true }
                },
                unknown_keys: "reject"
            } } }] } }], default: [] },
            max_length: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF array::len(array::distinct($p.params.name)) != array::len($p.params) {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", $p.language, { fields: { params: ["CORE_VALIDATION_DUPLICATE"] } });
    };
    IF !fn::auth_has_permission({ permission: "i18n.translation.manage" }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { permission: "i18n.translation.manage" });
    };
    LET $namespace = (SELECT id, source_locale FROM ONLY type::record("i18n_namespace", $p.namespace));
    IF $namespace == NONE {
        RETURN fn::error_result("I18N_NAMESPACE_NOT_FOUND", $p.language, { namespace: $p.namespace });
    };
    LET $full_key = string::concat($p.namespace, ".", $p.name);
    LET $id = type::record("i18n_key", $full_key);
    IF record::exists($id) {
        RETURN fn::error_result("I18N_KEY_EXISTS", $p.language, { key: $full_key });
    };
    LET $check = fn::i18n_message_check({ text: $p.source_text, syntax: $p.syntax, params: $p.params, locale: $namespace.source_locale, max_length: $p.max_length });
    IF array::len($check.problems) > 0 {
        RETURN fn::error_result("I18N_TRANSLATION_INVALID", $p.language, { problems: $check.problems });
    };
    LET $created = (CREATE ONLY $id CONTENT { namespace: $namespace.id, name: $p.name, description: $p.description, params: $p.params, max_length: $p.max_length });
    IF $created == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_key" });
    };
    -- Texte source : créé avec la clé ; son échec annule la clé (THROW, même transaction)
    LET $source = fn::i18n_translation_set({ key: $full_key, locale: <string> record::id($namespace.source_locale), text: $p.source_text, syntax: $p.syntax, language: $p.language });
    IF !$source.ok { THROW $source.error.code; };
    RETURN fn::result_ok({ key: $created, warnings: $check.warnings });
} COMMENT "Crée une clé et son texte source ({ namespace, name, source_text, syntax, description, params: [{ name, type }], max_length }) ; texte contrôlé (I18N_TRANSLATION_INVALID). { key, warnings }. Permission i18n.translation.manage";

-- ----------------------------------------------------------------------------
-- fn::i18n_key_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_key_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            params: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    name: { pipeline: [{ rule: "identifier", options: { min_length: 1, max_length: 64 } }], required: true },
                    type: { pipeline: [{ rule: "enum", options: { allowed: ["string", "number", "datetime"], case_sensitive: true } }], required: true }
                },
                unknown_keys: "reject"
            } } }] } }] },
            max_length: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_unique" }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["description", "max_length"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF $p.params IS NOT NONE AND array::len(array::distinct($p.params.name)) != array::len($p.params) {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", $p.language, { fields: { params: ["CORE_VALIDATION_DUPLICATE"] } });
    };
    IF !fn::auth_has_permission({ permission: "i18n.translation.manage" }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { permission: "i18n.translation.manage" });
    };
    LET $id = type::record("i18n_key", $p.key);
    LET $current = (SELECT *, namespace.source_locale AS source_locale FROM ONLY $id);
    IF $current == NONE {
        RETURN fn::error_result("I18N_KEY_NOT_FOUND", $p.language, { key: $p.key });
    };
    LET $new_params = $p.params ?? $current.params;
    -- Un champ absent est conservé ; clear efface explicitement
    LET $new_max = IF "max_length" IN $p.clear { NONE } ELSE { $p.max_length ?? $current.max_length };
    -- Le texte source doit rester conforme aux paramètres et à la longueur de la clé
    LET $source = (SELECT text, syntax FROM ONLY type::record("i18n_translation", [$p.key, <string> record::id($current.source_locale), "installation"]));
    LET $check = fn::i18n_message_check({ text: $source.text, syntax: $source.syntax, params: $new_params, locale: $current.source_locale, max_length: $new_max });
    IF array::len($check.problems) > 0 {
        RETURN fn::error_result("I18N_TRANSLATION_INVALID", $p.language, { problems: $check.problems });
    };
    LET $updated = (UPDATE ONLY $id SET
        description = IF "description" IN $p.clear { NONE } ELSE { $p.description ?? $current.description },
        params = $new_params,
        max_length = $new_max);
    IF $updated == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_key" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie une clé ({ key, description, params, max_length, clear }) : un champ absent est conservé, clear (description, max_length) efface ; le texte source est recontrôlé avec les nouveaux paramètres (I18N_TRANSLATION_INVALID). Permission i18n.translation.manage";

-- ----------------------------------------------------------------------------
-- fn::i18n_key_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_key_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "i18n.translation.manage" }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { permission: "i18n.translation.manage" });
    };
    LET $id = type::record("i18n_key", $p.key);
    IF !record::exists($id) {
        RETURN fn::error_result("I18N_KEY_NOT_FOUND", $p.language, { key: $p.key });
    };
    LET $translations = array::len(SELECT VALUE id FROM i18n_translation WHERE key = $id);
    LET $deleted = (DELETE ONLY $id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_key" });
    };
    RETURN fn::result_ok({ deleted: true, translations: $translations });
} COMMENT "Supprime une clé ({ key }) et tous ses textes, surcharges comprises ; { deleted, translations }. Permission i18n.translation.manage";

-- ----------------------------------------------------------------------------
-- fn::i18n_key_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_key_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            namespace: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            search: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
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
    LET $search = fn::sanitize_lowercase($p.search);
    LET $namespace = IF $p.namespace IS NONE { NONE } ELSE { type::record("i18n_namespace", $p.namespace) };
    LET $rows = (SELECT * FROM i18n_key
        WHERE ($namespace IS NONE OR namespace = $namespace)
            AND ($search IS NONE OR string::contains(full_key, $search))
        ORDER BY full_key);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Liste les clés ({ namespace, search (partie de la clé complète), limit, start }), triées par clé complète ; { items, total }";
