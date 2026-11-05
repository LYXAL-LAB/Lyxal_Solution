-- ============================================================================
-- FONCTION : fn::ingestion_manifest_record_exec
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement des résultats d'exécution et de publication du manifeste
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_record_exec($params: object) {
    LET $manifest_ref = <string> $params.manifest_ref;
    LET $statut = string::uppercase(<string> $params.statut);
    LET $items_committed = IF $params.items_committed != NONE { <int> $params.items_committed } ELSE { NONE };
    LET $items_failed = IF $params.items_failed != NONE { <int> $params.items_failed } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $manifests = (SELECT * FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
    IF array::len($manifests) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $language, { manifest_ref: $manifest_ref });
    };

    LET $manif = $manifests[0];
    LET $now = time::now();
    LET $operator = fn::ingestion_session_identity({}).operator;

    -- Un manifeste approuvé passe par EXECUTING avant son état final (machine à états)
    LET $executing = IF $manif.statut = "APPROVED" AND $statut = "COMMITTED" {
        (UPDATE ONLY $manif.id SET
            statut = "EXECUTING",
            transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [{
                from_state: "APPROVED",
                to_state: "EXECUTING",
                triggered_by: $operator,
                reason: "Début de la publication",
                transitioned_at: $now
            }]))
    } ELSE { $manif };
    IF $executing == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $language, { table: "ingestion_publication_manifest" });
    };

    LET $trans = {
        from_state: $executing.statut,
        to_state: $statut,
        triggered_by: $operator,
        reason: "Compte-rendu d'exécution de la publication",
        transitioned_at: $now
    };

    LET $updated = (UPDATE ONLY $manif.id SET
        statut = $statut,
        items_committed = IF $items_committed != NONE { $items_committed } ELSE { items_committed },
        items_failed = IF $items_failed != NONE { $items_failed } ELSE { items_failed },
        execution_items = IF $params.execution_items != NONE { $params.execution_items } ELSE { execution_items },
        executed_at = $now,
        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]));
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $language, { table: "ingestion_publication_manifest" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Consigne les métriques d'exécution de publication et l'audit trail associé";
