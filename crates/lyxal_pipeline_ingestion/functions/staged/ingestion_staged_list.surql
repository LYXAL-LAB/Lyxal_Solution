-- ============================================================================
-- FONCTION : fn::ingestion_staged_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Liste paginée et filtrée des articles en staging
-- APPEL    : externe (console Data Steward, publication), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }] },
            qualification: { pipeline: [{ rule: "enum", options: { allowed: ["VERIFIED", "TO_CONFIRM", "REJECTED"], case_sensitive: false } }] },
            fabricant: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            qualification: { pipeline: [{ rule: "uppercase" }] },
            fabricant: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 10);

    LET $total = count(SELECT VALUE id FROM ingestion_staged_item WHERE
        ($p.batch_id == NONE OR batch = $p.batch_id)
        AND ($p.qualification == NONE OR qualification = $p.qualification)
        AND ($p.fabricant == NONE OR fabricant = $p.fabricant));
    LET $items = (SELECT *,
            <string> record::id(id) AS id,
            <string> record::id(batch) AS batch,
            <string> record::id(raw_record) AS raw_record
        FROM ingestion_staged_item WHERE
            ($p.batch_id == NONE OR batch = $p.batch_id)
            AND ($p.qualification == NONE OR qualification = $p.qualification)
            AND ($p.fabricant == NONE OR fabricant = $p.fabricant)
        ORDER BY ligne_numero ASC
        LIMIT $p.limit START $p.start);

    RETURN fn::result_ok({ items: $items, total: $total, limit: $p.limit, start: $p.start });
} COMMENT "Retourne la liste paginée et filtrée (lot, qualification, fabricant) des articles en staging, triée par numéro de ligne";
