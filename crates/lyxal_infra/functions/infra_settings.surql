-- ============================================================================
-- FONCTIONS : réglages
-- MODULE    : lyxal_infra
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::infra_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_settings_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: { language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" } },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok(fn::infra__settings());
} COMMENT "Réglages effectifs ({ language }) : reconcile_minutes, default_ttl, min_ttl, max_deletions, max_deletion_percent, verify_timeout_hours, requests_per_second, change_retention_days, released_retention_days. Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_settings_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_settings_update($params: object) {
    LET $bounded = |$min: int, $max: int| { pipeline: [{ rule: "integer", options: { min_value: $min, max_value: $max } }] };
    LET $report = fn::validation_object_execute($params, {
        fields: {
            reconcile_minutes: $bounded(1, 1440),
            default_ttl: $bounded(60, 86400),
            min_ttl: $bounded(60, 86400),
            max_deletions: $bounded(0, 10000),
            max_deletion_percent: $bounded(0, 100),
            verify_timeout_hours: $bounded(1, 168),
            requests_per_second: $bounded(1, 100),
            change_retention_days: $bounded(1, 3650),
            released_retention_days: $bounded(1, 3650),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $merged = object::extend(fn::infra__settings(), object::remove($p, "language"));
    IF $merged.min_ttl > $merged.default_ttl {
        RETURN fn::error_result("INFRA_SETTINGS_INVALID", $p.language, { fields: { default_ttl: { code: "CORE_VALIDATION_TOO_SMALL", details: { min: $merged.min_ttl } } } });
    };
    LET $saved = (UPSERT ONLY infra_settings:installation CONTENT $merged);
    IF $saved == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_settings" }); };
    RETURN fn::result_ok(fn::infra__settings());
} COMMENT "Modifie les réglages ({ reconcile_minutes (1 à 1 440), default_ttl (60 à 86 400, au moins min_ttl), min_ttl, max_deletions (0 à 10 000), max_deletion_percent (0 à 100), verify_timeout_hours (1 à 168), requests_per_second (1 à 100), change_retention_days, released_retention_days (1 à 3 650) }) ; un champ absent est conservé. Rend les réglages effectifs. Droit infra.manage";
