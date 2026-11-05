-- ============================================================================
-- FONCTION : fn::ingestion_manifest_get_detail
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Détail d'un manifeste de publication et de son lot
-- APPEL    : externe (console Data Steward, publication), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_get_detail($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            manifest_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, { fields: { manifest_ref: { pipeline: [{ rule: "trim" }] } }, unknown_keys: "keep" }, 10);

    LET $found = (SELECT * FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $p.manifest_ref LIMIT 1);
    IF $found == NONE {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $p.language, { manifest_ref: $p.manifest_ref });
    };
    LET $manifest = object::extend($found, { id: <string> record::id($found.id), batch: <string> record::id($found.batch) });
    LET $batch = (SELECT *, <string> record::id(id) AS id FROM ONLY $found.batch);

    RETURN fn::result_ok({
        manifest: $manifest,
        batch: $batch,
        is_sealed: $manifest.is_sealed,
        seal_hash: $manifest.seal_hash,
        execution_count: array::len($manifest.execution_items ?? []),
        transition_count: array::len($manifest.transitions ?? [])
    });
} COMMENT "Retourne un manifeste de publication (référence), son lot, son scellement et le nombre d'exécutions et de transitions ; INGESTION_MANIFEST_NOT_FOUND sinon";
