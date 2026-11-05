-- ============================================================================
-- FONCTION : fn::ingestion_manifest_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Liste paginée et filtrée des manifestes de publication
-- APPEL    : externe (console Data Steward), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }] },
            statut: { pipeline: [{ rule: "enum", options: { allowed: ["DRAFT", "SEALED", "APPROVED", "EXECUTING", "COMMITTED", "FAILED"], case_sensitive: false } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { statut: { pipeline: [{ rule: "uppercase" }] } }, unknown_keys: "keep" }, 10);

    LET $total = count(SELECT VALUE id FROM ingestion_publication_manifest WHERE
        ($p.batch_id == NONE OR batch = $p.batch_id)
        AND ($p.statut == NONE OR statut = $p.statut));
    LET $manifests = (SELECT *,
            <string> record::id(id) AS id,
            <string> record::id(batch) AS batch
        FROM ingestion_publication_manifest WHERE
            ($p.batch_id == NONE OR batch = $p.batch_id)
            AND ($p.statut == NONE OR statut = $p.statut)
        ORDER BY created_at DESC
        LIMIT $p.limit START $p.start);

    RETURN fn::result_ok({ manifests: $manifests, total: $total, limit: $p.limit, start: $p.start });
} COMMENT "Retourne la liste paginée et filtrée (lot, statut) des manifestes de publication, du plus récent au plus ancien";
