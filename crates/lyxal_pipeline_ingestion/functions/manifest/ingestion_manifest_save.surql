-- ============================================================================
-- FONCTION : fn::ingestion_manifest_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un manifeste de publication brouillon ou scellé
-- APPEL    : interne (préparation de la publication), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_save($params: object) {
    LET $batch = fn::validation_record($params.batch_id, "ingestion_batch");
    IF !$batch.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "batch_id", reason: $batch.code }); };
    LET $checks = {
        manifest_ref: fn::validation_required_string($params.manifest_ref, 1, 128),
        manifest_version: fn::validation_integer($params.manifest_version ?? 1, 1, NONE),
        seal_hash: fn::validation_required_string($params.seal_hash, 64, 64),
        statut: fn::validation_enum($params.statut ?? "DRAFT", ["DRAFT", "SEALED"], false),
        nb_articles_insert: fn::validation_integer($params.nb_articles_insert ?? 0, 0, NONE),
        nb_articles_update: fn::validation_integer($params.nb_articles_update ?? 0, 0, NONE)
    };
    FOR $entry IN object::entries($checks) {
        IF !$entry[1].valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: $entry[0], reason: $entry[1].code }); };
    };

    LET $statut = string::uppercase($checks.statut.value);
    LET $content = {
        manifest_version: $checks.manifest_version.value,
        seal_hash: $checks.seal_hash.value,
        is_sealed: $statut == "SEALED",
        statut: $statut,
        nb_articles_insert: $checks.nb_articles_insert.value,
        nb_articles_update: $checks.nb_articles_update.value
    };
    LET $transition = {
        to_state: $statut,
        triggered_by: fn::ingestion_session_identity({}).operator,
        reason: IF $statut == "SEALED" { "Scellement du manifeste" } ELSE { "Préparation du manifeste" },
        transitioned_at: time::now()
    };

    LET $existing = (SELECT id, batch, statut, transitions FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $checks.manifest_ref.value LIMIT 1);
    IF $existing != NONE {
        -- Un manifeste approuvé, en cours d'exécution ou exécuté n'est plus modifiable
        IF $existing.statut NOT IN ["DRAFT", "SEALED"] OR $existing.batch != $batch.value {
            RETURN fn::error_result("INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION", NONE, { manifest_ref: $checks.manifest_ref.value, current_status: $existing.statut, requested_status: $statut });
        };
        LET $transitions = IF $existing.statut != $statut {
            array::append($existing.transitions ?? [], object::extend($transition, { from_state: $existing.statut }))
        } ELSE { $existing.transitions ?? [] };
        LET $updated = (UPDATE ONLY $existing.id MERGE object::extend($content, { transitions: $transitions }));
        IF $updated == NONE {
            RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_publication_manifest" });
        };
        RETURN fn::result_ok($checks.manifest_ref.value);
    };

    LET $created = (CREATE ONLY ingestion_publication_manifest CONTENT object::extend($content, {
        batch: $batch.value,
        manifest_ref: $checks.manifest_ref.value,
        transitions: [object::extend($transition, { from_state: NONE })]
    }));
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_publication_manifest" });
    };
    RETURN fn::result_ok($checks.manifest_ref.value);
} COMMENT "Enregistre un manifeste brouillon (DRAFT) ou scellé (SEALED, empreinte BLAKE3) ; modifiable tant qu'il n'est pas approuvé ; approbation et exécution passent par fn::ingestion_manifest_approve et fn::ingestion_manifest_record_exec";
