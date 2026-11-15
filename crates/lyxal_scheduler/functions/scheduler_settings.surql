-- ============================================================================
-- FONCTIONS : réglages
-- MODULE    : lyxal_scheduler
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::scheduler_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_settings_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok({
        own: (SELECT * FROM ONLY scheduler_settings WHERE scope_key = fn::scheduler_scope_key($p.tenant) LIMIT 1),
        effective: fn::scheduler_settings_effective({ tenant: $p.tenant })
    });
} COMMENT "Réglages d'une portée ({ tenant }) : { own, effective } (organisation, sinon installation, sinon valeurs par défaut). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_settings_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_settings_set($params: object) {
    LET $names = ["catchup_window", "run_retention", "keep_last_runs", "tenant_concurrency", "max_schedules", "max_pending_runs", "max_args_bytes"];
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            catchup_window: { pipeline: [{ rule: "duration", options: { min_value: 1m, max_value: 30d } }] },
            run_retention: { pipeline: [{ rule: "duration", options: { min_value: 1d, max_value: 3650d } }] },
            keep_last_runs: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000 } }] },
            tenant_concurrency: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }] },
            max_schedules: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000000 } }] },
            max_pending_runs: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000000 } }] },
            max_args_bytes: { pipeline: [{ rule: "integer", options: { min_value: 256, max_value: 1048576 } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: $names, case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "settings", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $existing = (SELECT id FROM ONLY scheduler_settings WHERE scope_key = fn::scheduler_scope_key($p.tenant) LIMIT 1);
    -- Champ fourni : remplacé ; champ dans clear : effacé ; sinon conservé
    LET $changes = object::from_entries(array::filter(
        array::map($names, |$f| [$f, IF $f IN $p.clear { NONE } ELSE { $p[$f] }]),
        |$e| $e[1] IS NOT NONE OR $e[0] IN $p.clear
    ));
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("scheduler_settings", fn::scheduler_scope_key($p.tenant)) CONTENT object::extend($changes, { tenant: $p.tenant }))
    } ELSE {
        (UPDATE ONLY $existing.id MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_settings" }); };
    RETURN fn::result_ok({ own: $saved, effective: fn::scheduler_settings_effective({ tenant: $p.tenant }) });
} COMMENT "Enregistre les réglages d'une portée ({ tenant, catchup_window (1 min à 30 jours), run_retention (1 à 3650 jours), keep_last_runs (0 à 1000), tenant_concurrency (1 à 10000), max_schedules, max_pending_runs, max_args_bytes (256 o à 1 Mio), clear }) : un champ fourni est remplacé, un champ nommé dans clear est effacé, les autres sont conservés ; renvoie { own, effective }. Droit : réglages (installation : scheduler.installation.manage)";
