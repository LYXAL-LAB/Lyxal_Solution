-- ============================================================================
-- FONCTIONS : résolution du texte d'une clé
-- MODULE    : lyxal_i18n
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::i18n_resolve_scope (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_resolve_scope($tenant: option<record<auth_organization>>) -> object {
    LET $system = fn::auth_session_valid({}).system;
    LET $context = fn::auth_context({});
    LET $own = IF $context.ok { $context.data.organization } ELSE { NONE };
    -- Résoudre pour une autre organisation que la sienne : session système, ou permission de
    -- lecture de tous les textes (compte de service, ex. worker d'envoi)
    IF $tenant IS NOT NONE AND !$system AND $tenant != $own AND !fn::auth_has_permission({ permission: "i18n.translation.read" }) { RETURN { allowed: false }; };
    LET $organization = $tenant ?? $own;
    RETURN {
        allowed: true,
        system: $system,
        scope: IF $organization IS NONE { NONE } ELSE { <string> record::id($organization) },
        default_chain: fn::i18n_locale_chain(<string> record::id((SELECT VALUE default_locale FROM ONLY i18n_settings:installation)))
    };
} COMMENT "Interne : portée d'une résolution ({ allowed, system, scope, default_chain }) : organisation demandée ou organisation active de l'appelant";

-- ----------------------------------------------------------------------------
-- fn::i18n_resolve_text (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_resolve_text($full_key: string, $locale: string, $scope: object) -> object {
    LET $key = (SELECT VALUE namespace.source_locale FROM ONLY type::record("i18n_key", $full_key));
    IF $key == NONE {
        -- Clé non déclarée : notée une fois par clé et par langue, pour la session système seulement
        IF $scope.system {
            LET $id = type::record("i18n_missing_key", [$full_key, $locale]);
            IF record::exists($id) { UPDATE $id SET last_seen_at = time::now(); }
            ELSE { CREATE $id CONTENT { full_key: $full_key, locale: $locale }; };
        };
        RETURN { key: $full_key, text: $full_key, syntax: "plain", locale: NONE, overridden: false, missing: true };
    };
    -- Langue demandée et son repli, langue par défaut et son repli, langue source ; pour chaque
    -- langue, la surcharge de l'organisation puis le texte de l'installation
    LET $chain = array::distinct(array::concat(fn::i18n_locale_chain($locale), $scope.default_chain, [<string> record::id($key)]));
    LET $ids = array::flatten(array::map($chain, |$tag| IF $scope.scope IS NONE {
        [type::record("i18n_translation", [$full_key, $tag, "installation"])]
    } ELSE {
        [type::record("i18n_translation", [$full_key, $tag, $scope.scope]), type::record("i18n_translation", [$full_key, $tag, "installation"])]
    }));
    LET $found = array::first(array::filter(array::map($ids, |$id| (SELECT text, syntax, locale, tenant FROM ONLY $id)), |$row| $row IS NOT NONE));
    RETURN {
        key: $full_key,
        text: $found.text,
        syntax: $found.syntax,
        locale: <string> record::id($found.locale),
        overridden: $found.tenant IS NOT NONE,
        missing: false
    };
} COMMENT "Interne : texte d'une clé pour une langue et une portée, avec repli ; clé non déclarée : la clé elle-même, missing vrai";

-- ----------------------------------------------------------------------------
-- fn::i18n_resolve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }], required: true },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $scope = fn::i18n_resolve_scope($p.tenant);
    IF !$scope.allowed {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { tenant: <string> $p.tenant });
    };
    RETURN fn::result_ok(fn::i18n_resolve_text($p.key, $p.locale, $scope));
} COMMENT "Texte d'une clé dans une langue ({ key, locale, tenant }) : langue demandée et son repli CLDR, langue par défaut, langue source ; surcharge de l'organisation (tenant, par défaut l'organisation active de l'appelant) avant le texte de l'installation. { key, text, syntax, locale, overridden, missing } ; clé non déclarée : text = la clé, missing vrai";

-- ----------------------------------------------------------------------------
-- fn::i18n_resolve_many
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_resolve_many($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            keys: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_length", options: { max_length: 500 } }, { rule: "each", options: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }] } }], required: true },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: true } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("I18N_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $scope = fn::i18n_resolve_scope($p.tenant);
    IF !$scope.allowed {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { tenant: <string> $p.tenant });
    };
    RETURN fn::result_ok(array::map($p.keys, |$key| fn::i18n_resolve_text($key, $p.locale, $scope)));
} COMMENT "Textes de plusieurs clés ({ keys (500 au plus), locale, tenant }), dans l'ordre demandé ; mêmes règles et même résultat par clé que fn::i18n_resolve";

-- ----------------------------------------------------------------------------
-- fn::i18n_missing_key_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::i18n_missing_key_list($params: object) {
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
    IF !fn::auth_has_permission({ permission: "i18n.translation.manage" }) {
        RETURN fn::error_result("I18N_PERMISSION_DENIED", $p.language, { permission: "i18n.translation.manage" });
    };
    LET $rows = (SELECT full_key AS key, locale, first_seen_at, last_seen_at FROM i18n_missing_key ORDER BY key, locale);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Clés demandées par l'hôte ou un worker mais non déclarées ({ limit, start }) : { items: [{ key, locale, first_seen_at, last_seen_at }], total }. Permission i18n.translation.manage";
