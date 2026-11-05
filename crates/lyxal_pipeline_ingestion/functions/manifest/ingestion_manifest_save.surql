-- ============================================================================
-- FONCTION : fn::ingestion_manifest_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un manifeste de publication brouillon ou scellé
-- APPEL    : préparation de la publication, entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            manifest_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            manifest_version: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], default: 1 },
            seal_hash: { pipeline: [{ rule: "required_string", options: { min_length: 64, max_length: 64 } }], required: true },
            statut: { pipeline: [{ rule: "enum", options: { allowed: ["DRAFT", "SEALED"], case_sensitive: false } }], default: "DRAFT" },
            nb_articles_insert: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            nb_articles_update: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: { manifest_ref: { pipeline: [{ rule: "trim" }] }, seal_hash: { pipeline: [{ rule: "trim" }, { rule: "lowercase" }] }, statut: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 10);
    LET $batch = { value: $p.batch_id };

    LET $statut = $p.statut;
    LET $content = {
        manifest_version: $p.manifest_version,
        seal_hash: $p.seal_hash,
        is_sealed: $statut == "SEALED",
        statut: $statut,
        nb_articles_insert: $p.nb_articles_insert,
        nb_articles_update: $p.nb_articles_update
    };
    LET $transition = {
        to_state: $statut,
        triggered_by: fn::ingestion_session_identity({}).operator,
        reason: IF $statut == "SEALED" { "Scellement du manifeste" } ELSE { "Préparation du manifeste" },
        transitioned_at: time::now()
    };

    LET $existing = (SELECT id, batch, statut, transitions FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $p.manifest_ref LIMIT 1);
    -- Une version par lot (index idx_manifest_batch_version) : refus métier plutôt qu'erreur d'index
    LET $same_version = (SELECT VALUE manifest_ref FROM ONLY ingestion_publication_manifest WHERE batch = $batch.value AND manifest_version = $p.manifest_version AND manifest_ref != $p.manifest_ref LIMIT 1);
    IF $same_version != NONE {
        RETURN fn::error_result("INGESTION_MANIFEST_VERSION_DUPLICATE", $p.language, { batch_id: <string> record::id($batch.value), manifest_version: $p.manifest_version, manifest_ref: $same_version });
    };
    IF $existing != NONE {
        -- Un manifeste approuvé, en cours d'exécution ou exécuté n'est plus modifiable
        IF $existing.statut NOT IN ["DRAFT", "SEALED"] OR $existing.batch != $batch.value {
            RETURN fn::error_result("INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION", $p.language, { manifest_ref: $p.manifest_ref, current_status: $existing.statut, requested_status: $statut });
        };
        LET $transitions = IF $existing.statut != $statut {
            array::append($existing.transitions ?? [], object::extend($transition, { from_state: $existing.statut }))
        } ELSE { $existing.transitions ?? [] };
        LET $updated = (UPDATE ONLY $existing.id MERGE object::extend($content, { transitions: $transitions }));
        IF $updated == NONE {
            RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
        };
        RETURN fn::result_ok($p.manifest_ref);
    };

    LET $created = (CREATE ONLY ingestion_publication_manifest CONTENT object::extend($content, {
        batch: $batch.value,
        manifest_ref: $p.manifest_ref,
        transitions: [object::extend($transition, { from_state: NONE })]
    }));
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
    };
    RETURN fn::result_ok($p.manifest_ref);
} COMMENT "Enregistre un manifeste brouillon (DRAFT) ou scellé (SEALED, empreinte BLAKE3) ; modifiable tant qu'il n'est pas approuvé ; approbation et exécution passent par fn::ingestion_manifest_approve et fn::ingestion_manifest_record_exec";
