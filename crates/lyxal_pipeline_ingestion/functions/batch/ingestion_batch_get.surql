-- ============================================================================
-- FONCTION : fn::ingestion_batch_get
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Lecture d'un lot d'ingestion
-- APPEL    : interne (worker) et console, entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_get($params: object) {
    LET $id = fn::validation_record($params.id, "ingestion_batch");
    IF !$id.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "id", reason: $id.code }); };

    LET $batch = (SELECT *, <string> record::id(id) AS id, <string> source_object AS source_object FROM ONLY $id.value);
    IF $batch == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", NONE, { batch_id: <string> record::id($id.value) });
    };
    RETURN fn::result_ok($batch);
} COMMENT "Retourne un lot d'ingestion (identifiant court, fichier source en texte storage_object:<clé>, statut, compteurs, transitions) ; INGESTION_BATCH_NOT_FOUND sinon";
