-- ============================================================================
-- FONCTIONS : tâches du worker
-- MODULE    : lyxal_secrets
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::secrets_purge_due
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_purge_due($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "worker" }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $due = (SELECT VALUE id FROM secrets_secret WHERE state = "deleted" AND purge_at <= time::now() ORDER BY purge_at ASC LIMIT $p.limit);
    LET $purged = array::filter(array::map($due, |$id| (DELETE ONLY $id RETURN BEFORE)), |$s| $s IS NOT NONE);
    -- Tickets de lecture échus depuis plus d'un jour
    LET $tickets = (DELETE secrets_read_ticket WHERE expires_at < time::now() - 1d RETURN BEFORE);
    RETURN fn::result_ok({ purged: array::len($purged), tickets_removed: array::len($tickets) });
} COMMENT "Purge les secrets supprimés dont la date de purge est passée ({ limit (1000 au plus) }) et retire les tickets de lecture échus depuis plus d'un jour : { purged, tickets_removed }. Droit : worker";
