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
    LET $trans = {
        from_state: $manif.statut,
        to_state: $statut,
        triggered_by: "catalogue_sync_agent",
        reason: "Compte-rendu d'exécution de la publication",
        transitioned_at: $now
    };

    UPDATE $manif.id SET
        statut = $statut,
        items_committed = IF $items_committed != NONE { $items_committed } ELSE { items_committed },
        items_failed = IF $items_failed != NONE { $items_failed } ELSE { items_failed },
        execution_items = IF $params.execution_items != NONE { $params.execution_items } ELSE { execution_items },
        executed_at = $now,
        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);

    RETURN fn::result_ok(true);
} COMMENT "Consigne les métriques d'exécution de publication et l'audit trail associé";
