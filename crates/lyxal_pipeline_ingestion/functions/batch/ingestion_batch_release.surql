-- ============================================================================
-- FONCTION : fn::ingestion_batch_release
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Libération de la réservation d'un lot par l'exécution qui la détient
-- APPEL    : interne (worker, à la fin de chaque traitement), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_release($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            owner: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            generation: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Seule l'exécution détentrice libère : une exécution refusée ou écartée ne libère jamais la
    -- réservation d'une autre
    LET $released = (UPDATE ONLY $p.id SET claim_owner = NONE, claim_until = NONE, claim_ttl = NONE
        WHERE claim_owner = $p.owner AND claim_generation = $p.generation);
    IF $released == NONE {
        RETURN fn::error_result("INGESTION_BATCH_CLAIM_LOST", $p.language, { batch_id: <string> record::id($p.id) });
    };
    RETURN fn::result_ok(true);
} COMMENT "Libère la réservation d'un lot si elle est encore détenue par cette exécution (jeton et génération) ; sinon INGESTION_BATCH_CLAIM_LOST, sans rien modifier";
