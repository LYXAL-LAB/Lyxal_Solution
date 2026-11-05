-- ============================================================================
-- FONCTION : fn::ingestion_batch_checkpoint
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Point de reprise (checkpoint) du worker supervisé
-- APPEL    : interne (worker, une fois par bloc), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_checkpoint($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            cursor_offset: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            total_lignes: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            lignes_verifiees: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            lignes_a_confirmer: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            lignes_rejetees: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $id = { value: $p.id };

    LET $updated = (UPDATE ONLY $id.value SET
        cursor_offset = $p.cursor_offset,
        total_lignes = $p.total_lignes,
        lignes_verifiees = $p.lignes_verifiees,
        lignes_a_confirmer = $p.lignes_a_confirmer,
        lignes_rejetees = $p.lignes_rejetees,
        last_checkpoint_at = time::now());
    IF $updated == NONE {
        IF !record::exists($id.value) {
            RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", $p.language, { batch_id: <string> record::id($id.value) });
        };
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Met à jour l'avancement d'un lot et horodate le point de reprise sur incident";
