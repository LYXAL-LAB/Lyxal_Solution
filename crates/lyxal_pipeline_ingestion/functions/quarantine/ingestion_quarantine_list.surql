-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Liste paginée et filtrée des anomalies en quarantaine
-- APPEL    : externe (console Data Steward), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }] },
            severite: { pipeline: [{ rule: "enum", options: { allowed: ["CRITICAL", "ERROR", "WARNING"], case_sensitive: false } }] },
            is_resolved: { pipeline: [{ rule: "boolean" }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { severite: { pipeline: [{ rule: "uppercase" }] } }, unknown_keys: "keep" }, 10);

    LET $total = count(SELECT VALUE id FROM ingestion_quarantine_record WHERE
        ($p.batch_id == NONE OR batch = $p.batch_id)
        AND ($p.severite == NONE OR severite = $p.severite)
        AND ($p.is_resolved == NONE OR is_resolved = $p.is_resolved));
    LET $records = (SELECT *,
            <string> record::id(id) AS id,
            <string> record::id(batch) AS batch,
            <string> record::id(raw_record) AS raw_record
        FROM ingestion_quarantine_record WHERE
            ($p.batch_id == NONE OR batch = $p.batch_id)
            AND ($p.severite == NONE OR severite = $p.severite)
            AND ($p.is_resolved == NONE OR is_resolved = $p.is_resolved)
        ORDER BY ligne_numero ASC, created_at ASC
        LIMIT $p.limit START $p.start);

    RETURN fn::result_ok({ records: $records, total: $total, limit: $p.limit, start: $p.start });
} COMMENT "Retourne la liste paginée et filtrée (lot, sévérité, résolution) des anomalies en quarantaine, triée par numéro de ligne";
