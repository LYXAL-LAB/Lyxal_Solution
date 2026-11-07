-- ============================================================================
-- FONCTION : fn::ingestion_manifest_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un manifeste de publication brouillon ou scellé ; au scellement, le
--            serveur fige le contenu publié (fn::ingestion_manifest_content), calcule son sceau
--            BLAKE3 et verrouille les articles du lot (ingestion_batch.sealed_manifest)
-- APPEL    : préparation de la publication, entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            manifest_ref: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            manifest_version: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], default: 1 },
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
        fields: { manifest_ref: { pipeline: [{ rule: "trim" }] }, statut: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 10);
    LET $batch = { value: $p.batch_id };
    LET $statut = $p.statut;

    LET $existing = (SELECT id, batch, statut, transitions FROM ONLY ingestion_publication_manifest WHERE manifest_ref = $p.manifest_ref LIMIT 1);
    -- Une version par lot (index idx_manifest_batch_version) : refus métier plutôt qu'erreur d'index
    LET $same_version = (SELECT VALUE manifest_ref FROM ONLY ingestion_publication_manifest WHERE batch = $batch.value AND manifest_version = $p.manifest_version AND manifest_ref != $p.manifest_ref LIMIT 1);
    IF $same_version != NONE {
        RETURN fn::error_result("INGESTION_MANIFEST_VERSION_DUPLICATE", $p.language, { batch_id: <string> record::id($batch.value), manifest_version: $p.manifest_version, manifest_ref: $same_version });
    };
    -- Modifiable en brouillon ou scellé ; un manifeste en échec se rouvre seulement en brouillon
    -- (correction des articles, puis nouveau scellement et nouvelle approbation)
    IF $existing != NONE AND (
        $existing.batch != $batch.value
        OR $existing.statut NOT IN ["DRAFT", "SEALED", "FAILED"]
        OR ($existing.statut = "FAILED" AND $statut != "DRAFT")
    ) {
        RETURN fn::error_result("INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION", $p.language, { manifest_ref: $p.manifest_ref, current_status: $existing.statut, requested_status: $statut });
    };
    -- Un seul manifeste scellé à la fois par lot
    LET $sealed_by = (SELECT VALUE sealed_manifest FROM ONLY $batch.value);
    IF $statut = "SEALED" AND $sealed_by != NONE AND $sealed_by != $p.manifest_ref {
        RETURN fn::error_result("INGESTION_STAGED_ITEM_SEALED", $p.language, { batch_id: <string> record::id($batch.value), manifest_ref: $sealed_by });
    };

    -- Contenu publié et sceau calculés par le serveur au scellement ; un brouillon n'en a pas
    LET $published = IF $statut = "SEALED" { fn::ingestion_manifest_content({ batch_id: <string> $batch.value, language: $p.language }) } ELSE { NONE };
    IF $published != NONE AND !$published.ok { RETURN $published; };
    LET $contenu = $published.data;
    LET $content = {
        manifest_version: $p.manifest_version,
        contenu: $contenu,
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

    LET $saved = IF $existing != NONE {
        LET $transitions = IF $existing.statut != $statut {
            array::append($existing.transitions ?? [], object::extend($transition, { from_state: $existing.statut }))
        } ELSE { $existing.transitions ?? [] };
        UPDATE ONLY $existing.id MERGE object::extend($content, { transitions: $transitions })
    } ELSE {
        CREATE ONLY ingestion_publication_manifest CONTENT object::extend($content, {
            batch: $batch.value,
            manifest_ref: $p.manifest_ref,
            transitions: [object::extend($transition, { from_state: NONE })]
        })
    };
    IF $saved == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_publication_manifest" });
    };
    -- Sceau calculé sur le contenu tel qu'il est stocké (la base normalise la valeur à
    -- l'écriture), pour que le contrôle de fn::ingestion_manifest_get_detail le retrouve à l'identique
    LET $sealed = (UPDATE ONLY $saved.id SET seal_hash = IF contenu == NONE { NONE } ELSE { crypto::blake3(<string> contenu) });
    IF $sealed == NONE { THROW "INGESTION_WRITE_FORBIDDEN: sceau du manifeste refusé (ingestion_publication_manifest)"; };

    -- Verrou des articles du lot : posé au scellement, retiré quand ce manifeste revient en brouillon.
    -- Le manifeste vient d'être écrit : un verrou refusé annule toute l'opération (THROW) plutôt
    -- que de laisser un manifeste scellé sur des articles modifiables.
    LET $lock = IF $statut = "SEALED" { $p.manifest_ref } ELSE IF $sealed_by = $p.manifest_ref { NONE } ELSE { $sealed_by };
    IF $lock != $sealed_by {
        LET $locked = (UPDATE ONLY $batch.value SET sealed_manifest = $lock);
        IF $locked == NONE { THROW "INGESTION_WRITE_FORBIDDEN: verrou du lot refusé (ingestion_batch)"; };
    };
    RETURN fn::result_ok($p.manifest_ref);
} COMMENT "Enregistre un manifeste brouillon (DRAFT) ou scellé (SEALED) ; au scellement, le serveur fige le contenu publié, calcule son sceau BLAKE3 et verrouille les articles du lot, retirés du verrou à la remise en brouillon ; un manifeste en échec se rouvre en brouillon ; approbation et exécution passent par fn::ingestion_manifest_approve et fn::ingestion_manifest_record_exec";
