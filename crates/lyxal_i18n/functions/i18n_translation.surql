-- ============================================================================
-- FONCTIONS : traductions (textes de l'installation et surcharges par organisation)
-- MODULE    : lyxal_i18n
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::i18n_translation_target (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_translation_target($params: object) -> object {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }], required: true },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            text: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 10000 } }] },
            syntax: { pipeline: [{ rule: "enum", options: { allowed: ["icu_mf1", "plain"], case_sensitive: true } }] },
            reviewed: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN { error: fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field }) };
    };
    LET $p = $report.value;
    IF !fn::i18n_can_translate({ tenant: $p.tenant }) {
        RETURN { error: fn::error_result("I18N_PERMISSION_DENIED", $p.language, {
            permission: IF $p.tenant IS NONE { "i18n.translation.manage" } ELSE { "i18n.organization.translation.manage" }
        }) };
    };
    LET $key = (SELECT *, namespace.source_locale AS source_locale FROM ONLY type::record("i18n_key", $p.key));
    IF $key == NONE { RETURN { error: fn::error_result("I18N_KEY_NOT_FOUND", $p.language, { key: $p.key }) }; };
    LET $locale = type::record("i18n_locale", $p.locale);
    IF !record::exists($locale) { RETURN { error: fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $p.locale }) }; };
    RETURN {
        error: NONE,
        input: $p,
        key: $key,
        locale: $locale,
        id: type::record("i18n_translation", [$p.key, $p.locale, IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) }])
    };
} COMMENT "Interne : valide la cible d'une écriture ({ key, locale, tenant, … }) et les droits de l'appelant ; { error } ou { input, key, locale, id }";

-- ----------------------------------------------------------------------------
-- fn::i18n_translation_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_translation_set($params: object) {
    IF "reviewed" IN object::keys($params) OR $params.text IS NONE {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: { text: ["CORE_VALIDATION_REQUIRED"] } });
    };
    LET $target = fn::i18n_translation_target($params);
    IF $target.error IS NOT NONE { RETURN $target.error; };
    LET $p = $target.input;
    LET $current = (SELECT syntax, revision FROM ONLY $target.id);
    -- Syntaxe : celle demandée, sinon celle du texte existant, sinon celle du texte source
    LET $syntax = $p.syntax ?? $current.syntax
        ?? (SELECT VALUE syntax FROM ONLY type::record("i18n_translation", [$p.key, <string> record::id($target.key.source_locale), "installation"]))
        ?? "icu_mf1";
    LET $check = fn::i18n_message_check({ text: $p.text, syntax: $syntax, params: $target.key.params, locale: $target.locale, max_length: $target.key.max_length });
    IF array::len($check.problems) > 0 {
        RETURN fn::error_result("I18N_TRANSLATION_INVALID", $p.language, { problems: $check.problems });
    };
    LET $context = fn::auth_context({});
    LET $author = IF $context.ok { $context.data.identity } ELSE { NONE };
    LET $written = IF $current == NONE {
        (CREATE ONLY $target.id CONTENT { key: $target.key.id, locale: $target.locale, tenant: $p.tenant, text: $p.text, syntax: $syntax, state: "translated", updated_by: $author })
    } ELSE {
        (UPDATE ONLY $target.id SET text = $p.text, syntax = $syntax, state = "translated", revision = $current.revision + 1, updated_by = $author)
    };
    IF $written == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_translation" });
    };
    -- Relu après l'événement d'écriture (empreinte du texte source, obsolescence levée)
    RETURN fn::result_ok({ translation: (SELECT * FROM ONLY $target.id), warnings: $check.warnings });
} COMMENT "Écrit le texte d'une clé dans une langue ({ key, locale, text, syntax, tenant }) : texte de l'installation, ou surcharge de l'organisation tenant ; syntaxe par défaut : celle du texte source ; texte contrôlé (I18N_TRANSLATION_INVALID), état translated, obsolescence levée. { translation, warnings }. Permission i18n.translation.manage, ou i18n.organization.translation.manage pour son organisation";

-- ----------------------------------------------------------------------------
-- fn::i18n_translation_review
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_translation_review($params: object) {
    IF "text" IN object::keys($params) OR "syntax" IN object::keys($params) OR $params.reviewed IS NONE {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: { reviewed: ["CORE_VALIDATION_REQUIRED"] } });
    };
    LET $target = fn::i18n_translation_target($params);
    IF $target.error IS NOT NONE { RETURN $target.error; };
    LET $p = $target.input;
    LET $current = (SELECT outdated FROM ONLY $target.id);
    IF $current == NONE {
        RETURN fn::error_result("I18N_TRANSLATION_NOT_FOUND", $p.language, { key: $p.key, locale: $p.locale });
    };
    IF $p.reviewed AND $current.outdated {
        RETURN fn::error_result("I18N_TRANSLATION_OUTDATED", $p.language, { key: $p.key, locale: $p.locale });
    };
    LET $updated = (UPDATE ONLY $target.id SET state = IF $p.reviewed { "reviewed" } ELSE { "translated" });
    IF $updated == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_translation" });
    };
    RETURN fn::result_ok($updated);
} COMMENT "Marque un texte relu ou non ({ key, locale, reviewed, tenant }) ; un texte obsolète ne peut pas être marqué relu (I18N_TRANSLATION_OUTDATED). Mêmes permissions que fn::i18n_translation_set";

-- ----------------------------------------------------------------------------
-- fn::i18n_translation_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_translation_delete($params: object) {
    IF array::any(["text", "syntax", "reviewed"], |$k| $k IN object::keys($params)) {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: {} });
    };
    LET $target = fn::i18n_translation_target($params);
    IF $target.error IS NOT NONE { RETURN $target.error; };
    LET $p = $target.input;
    LET $current = (SELECT is_source FROM ONLY $target.id);
    IF $current == NONE {
        RETURN fn::error_result("I18N_TRANSLATION_NOT_FOUND", $p.language, { key: $p.key, locale: $p.locale });
    };
    IF $current.is_source {
        RETURN fn::error_result("I18N_SOURCE_REQUIRED", $p.language, { key: $p.key });
    };
    LET $deleted = (DELETE ONLY $target.id RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("I18N_WRITE_FORBIDDEN", $p.language, { table: "i18n_translation" });
    };
    RETURN fn::result_ok({ deleted: true });
} COMMENT "Supprime un texte ({ key, locale, tenant }) ; le texte source d'une clé ne se supprime pas (I18N_SOURCE_REQUIRED). Mêmes permissions que fn::i18n_translation_set";

-- ----------------------------------------------------------------------------
-- fn::i18n_translation_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_translation_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            namespace: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["untranslated", "translated", "reviewed"], case_sensitive: true } }] },
            outdated: { pipeline: [{ rule: "boolean" }] },
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
    IF !record::exists(type::record("i18n_locale", $p.locale)) {
        RETURN fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $p.locale });
    };
    IF !fn::i18n_can_read({ tenant: $p.tenant }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { tenant: <string> $p.tenant });
    };
    LET $search = fn::sanitize_lowercase($p.search);
    LET $namespace = IF $p.namespace IS NONE { NONE } ELSE { type::record("i18n_namespace", $p.namespace) };
    LET $scope = IF $p.tenant IS NONE { NONE } ELSE { <string> record::id($p.tenant) };
    LET $keys = (SELECT full_key, namespace.source_locale AS source_locale FROM i18n_key
        WHERE ($namespace IS NONE OR namespace = $namespace)
            AND ($search IS NONE OR string::contains(full_key, $search))
        ORDER BY full_key);
    -- Pour chaque clé : texte source, texte de l'installation et surcharge de l'organisation demandée
    LET $rows = array::map($keys, |$k| {
        LET $installation = (SELECT text, state, outdated FROM ONLY type::record("i18n_translation", [$k.full_key, $p.locale, "installation"]));
        LET $override = IF $scope IS NONE { NONE } ELSE { (SELECT text, state, outdated FROM ONLY type::record("i18n_translation", [$k.full_key, $p.locale, $scope])) };
        LET $row = $override ?? $installation;
        RETURN {
            key: $k.full_key,
            source_text: (SELECT VALUE text FROM ONLY type::record("i18n_translation", [$k.full_key, <string> record::id($k.source_locale), "installation"])),
            text: $row.text,
            state: $row.state ?? "untranslated",
            outdated: $row.outdated ?? false,
            overridden: $override IS NOT NONE
        };
    });
    LET $filtered = array::filter($rows, |$r| ($p.state IS NONE OR $r.state = $p.state) AND ($p.outdated IS NONE OR $r.outdated = $p.outdated));
    RETURN fn::result_ok({ items: array::slice($filtered, $p.start, $p.start + $p.limit), total: array::len($filtered) });
} COMMENT "État des traductions d'une langue ({ locale, namespace, tenant, state (untranslated, translated, reviewed), outdated, search, limit, start }) : une ligne par clé { key, source_text, text, state, outdated, overridden } ; avec tenant, la surcharge de l'organisation remplace le texte de l'installation";
