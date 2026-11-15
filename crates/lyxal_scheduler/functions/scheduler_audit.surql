-- ============================================================================
-- FONCTIONS : journal des actions
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Le journal est écrit par les DEFINE EVENT du module (fn::scheduler_audit_write), dans la
-- transaction de l'action journalisée.

-- ----------------------------------------------------------------------------
-- fn::scheduler_audit_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_audit_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            schedule: { pipeline: fn::scheduler_ref("scheduler_schedule") },
            action: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            since: { pipeline: [{ rule: "datetime" }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $schedule = IF $p.schedule IS NONE { NONE } ELSE { <string> $p.schedule };
    LET $all = (SELECT * FROM scheduler_audit
        WHERE scope_key = fn::scheduler_scope_key($p.tenant)
            AND ($schedule IS NONE OR schedule = $schedule)
            AND ($p.action IS NONE OR action = $p.action)
            AND ($p.since IS NONE OR created_at >= $p.since)
        ORDER BY created_at DESC, id DESC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Entrées du journal d'une portée ({ tenant, schedule, action, since, limit (500 au plus), start }), les plus récentes d'abord : { items, total }. Droit : lecture";
