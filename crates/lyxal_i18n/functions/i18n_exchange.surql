-- ============================================================================
-- FONCTIONS : export, import et parcours des textes
-- MODULE    : lyxal_i18n
-- ============================================================================
-- Un export ou un import porte une langue et une portée (installation, ou une organisation).
-- Les fichiers (JSON, XLIFF) sont lus et écrits par le Rust (lyxal_parsing).

-- ----------------------------------------------------------------------------
-- fn::i18n_export
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_export($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            namespace: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 500 },
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
    LET $namespace = IF $p.namespace IS NONE { NONE } ELSE { type::record("i18n_namespace", $p.namespace) };
    IF $namespace IS NOT NONE AND !record::exists($namespace) {
        RETURN fn::error_result("I18N_NAMESPACE_NOT_FOUND", $p.language, { namespace: $p.namespace });
    };
    LET $scope = IF $p.tenant IS NONE { NONE } ELSE { <string> record::id($p.tenant) };
    LET $keys = (SELECT full_key, description, params, max_length, <string> record::id(namespace) AS namespace,
            <string> record::id(namespace.source_locale) AS source_locale
        FROM i18n_key WHERE $namespace IS NONE OR namespace = $namespace ORDER BY full_key);
    LET $page = array::slice($keys, $p.start, $p.start + $p.limit);
    LET $items = array::map($page, |$k| {
        LET $source = (SELECT text, syntax FROM ONLY type::record("i18n_translation", [$k.full_key, $k.source_locale, "installation"]));
        LET $installation = (SELECT text, syntax, state, outdated FROM ONLY type::record("i18n_translation", [$k.full_key, $p.locale, "installation"]));
        LET $override = IF $scope IS NONE { NONE } ELSE { (SELECT text, syntax, state, outdated FROM ONLY type::record("i18n_translation", [$k.full_key, $p.locale, $scope])) };
        LET $row = $override ?? $installation;
        RETURN {
            key: $k.full_key,
            namespace: $k.namespace,
            description: $k.description,
            params: $k.params,
            max_length: $k.max_length,
            source_locale: $k.source_locale,
            source_text: $source.text,
            source_syntax: $source.syntax,
            text: $row.text,
            syntax: $row.syntax ?? $source.syntax,
            state: $row.state ?? "untranslated",
            outdated: $row.outdated ?? false,
            overridden: $override IS NOT NONE
        };
    });
    RETURN fn::result_ok({ items: $items, total: array::len($keys) });
} COMMENT "Textes d'une langue à exporter ({ locale, namespace, tenant, limit (500), start }) : une ligne par clé { key, namespace, description, params, max_length, source_locale, source_text, source_syntax, text, syntax, state, outdated, overridden }, triées par clé ; avec tenant, la surcharge de l'organisation remplace le texte de l'installation. { items, total }";

-- ----------------------------------------------------------------------------
-- fn::i18n_import_entry (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_import_entry($entry: object, $context: object) -> object {
    LET $key = (SELECT params, max_length, <string> record::id(namespace.source_locale) AS source_locale FROM ONLY type::record("i18n_key", $entry.key));
    IF $key == NONE { RETURN { key: $entry.key, outcome: "skipped", reason: "key_not_found" }; };
    LET $current = (SELECT text, syntax, state FROM ONLY type::record("i18n_translation", [$entry.key, $context.locale, $context.scope]));
    LET $syntax = $entry.syntax ?? $current.syntax
        ?? (SELECT VALUE syntax FROM ONLY type::record("i18n_translation", [$entry.key, $key.source_locale, "installation"]))
        ?? "icu_mf1";
    IF $current IS NOT NONE AND $current.text = $entry.text AND $current.syntax = $syntax {
        RETURN { key: $entry.key, outcome: "unchanged" };
    };
    IF $current.state = "reviewed" AND !$context.overwrite_reviewed {
        RETURN { key: $entry.key, outcome: "skipped", reason: "reviewed" };
    };
    LET $check = fn::i18n_message_check({ text: $entry.text, syntax: $syntax, params: $key.params, locale: type::record("i18n_locale", $context.locale), max_length: $key.max_length });
    IF array::len($check.problems) > 0 {
        RETURN { key: $entry.key, outcome: "invalid", problems: $check.problems };
    };
    LET $outcome = IF $current IS NONE { "created" } ELSE { "updated" };
    IF $context.dry_run { RETURN { key: $entry.key, outcome: $outcome }; };
    LET $written = fn::i18n_translation_set({ key: $entry.key, locale: $context.locale, text: $entry.text, syntax: $syntax, tenant: $context.tenant, language: $context.language });
    IF !$written.ok { RETURN { key: $entry.key, outcome: "skipped", reason: $written.error.code }; };
    RETURN { key: $entry.key, outcome: $outcome };
} COMMENT "Interne : importe une entrée ({ key, text, syntax }) dans la langue et la portée du contexte ; { key, outcome (created, updated, unchanged, skipped, invalid), reason, problems }";

-- ----------------------------------------------------------------------------
-- fn::i18n_import
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_import($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            entries: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_length", options: { max_length: 500 } }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    key: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }], required: true },
                    text: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 10000 } }], required: true },
                    syntax: { pipeline: [{ rule: "enum", options: { allowed: ["icu_mf1", "plain"], case_sensitive: true } }] }
                },
                unknown_keys: "reject"
            } } }] } }], required: true },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            overwrite_reviewed: { pipeline: [{ rule: "boolean" }], default: false },
            dry_run: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF array::len(array::distinct($p.entries.key)) != array::len($p.entries) {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", $p.language, { fields: { entries: ["CORE_VALIDATION_DUPLICATE"] } });
    };
    IF !fn::i18n_can_translate({ tenant: $p.tenant }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, {
            permission: IF $p.tenant IS NONE { "i18n.translation.manage" } ELSE { "i18n.organization.translation.manage" }
        });
    };
    IF !record::exists(type::record("i18n_locale", $p.locale)) {
        RETURN fn::error_result("I18N_LOCALE_NOT_FOUND", $p.language, { locale: $p.locale });
    };
    LET $context = {
        locale: $p.locale,
        tenant: IF $p.tenant IS NONE { NONE } ELSE { <string> $p.tenant },
        scope: IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) },
        overwrite_reviewed: $p.overwrite_reviewed,
        dry_run: $p.dry_run,
        language: $p.language
    };
    -- Entrées indépendantes : une entrée refusée n'empêche pas les autres
    LET $outcomes = array::map($p.entries, |$entry| fn::i18n_import_entry($entry, $context));
    RETURN fn::result_ok({
        created: array::len(array::filter($outcomes, |$o| $o.outcome = "created")),
        updated: array::len(array::filter($outcomes, |$o| $o.outcome = "updated")),
        unchanged: array::len(array::filter($outcomes, |$o| $o.outcome = "unchanged")),
        skipped: array::map(array::filter($outcomes, |$o| $o.outcome = "skipped"), |$o| { key: $o.key, reason: $o.reason }),
        invalid: array::map(array::filter($outcomes, |$o| $o.outcome = "invalid"), |$o| { key: $o.key, problems: $o.problems })
    });
} COMMENT "Importe des textes dans une langue et une portée ({ locale, entries: [{ key, text, syntax }] (500 au plus), tenant, overwrite_reviewed, dry_run }) : clé non déclarée ignorée (key_not_found), texte identique inchangé, texte relu ignoré sauf overwrite_reviewed (reviewed), texte refusé par le contrôle (invalid, non écrit) ; dry_run ne modifie rien. { created, updated, unchanged, skipped: [{ key, reason }], invalid: [{ key, problems }] }. Mêmes permissions que fn::i18n_translation_set";

-- ----------------------------------------------------------------------------
-- fn::i18n_translation_scan
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_translation_scan($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 500 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
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
    LET $rows = (SELECT key.full_key AS key, <string> record::id(locale) AS locale,
            IF tenant IS NONE { NONE } ELSE { <string> tenant } AS tenant, scope_key, text, syntax
        FROM i18n_translation ORDER BY key, locale, scope_key);
    RETURN fn::result_ok({
        items: array::map(array::slice($rows, $p.start, $p.start + $p.limit), |$r| { key: $r.key, locale: $r.locale, tenant: $r.tenant, text: $r.text, syntax: $r.syntax }),
        total: array::len($rows)
    });
} COMMENT "Tous les textes, toutes langues et toutes portées ({ limit (500), start }), triés par clé, langue et portée, pour le contrôle de leur syntaxe par le rendu : { items: [{ key, locale, tenant, text, syntax }], total }. Permission i18n.translation.manage";
