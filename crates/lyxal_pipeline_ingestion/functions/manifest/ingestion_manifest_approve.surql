-- ============================================================================
-- FONCTION : fn::ingestion_manifest_approve
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Approbation formelle du manifeste de publication par le Data Steward
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_approve($params: object) {
    LET $manifest_ref = <string> $params.manifest_ref;
    LET $approved_by = <string> $params.approved_by;
    LET $approver_role = IF $params.approver_role != NONE { <string> $params.approver_role } ELSE { "steward_admin" };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $manifests = (SELECT * FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
    IF array::len($manifests) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $language, { manifest_ref: $manifest_ref });
    };

    LET $manif = $manifests[0];

    -- Vérification du scellement
    IF $manif.is_sealed != true OR string::len($manif.seal_hash) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_UNSEALED", $language, { manifest_ref: $manifest_ref });
    };

    -- Contrôle d'habilitation
    IF $approver_role != "steward_admin" {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $language, { 
            manifest_ref: $manifest_ref, 
            role: $approver_role, 
            expected_role: "steward_admin" 
        });
    };

    LET $now = time::now();
    LET $trans = {
        from_state: $manif.statut,
        to_state: "APPROVED",
        triggered_by: $approved_by,
        reason: "Approbation formelle du Data Steward",
        transitioned_at: $now
    };

    UPDATE $manif.id SET
        statut = "APPROVED",
        approved_by = $approved_by,
        approver_role = "steward_admin",
        approved_at = $now,
        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);

    RETURN fn::result_ok(true);
} COMMENT "Valide formellement un manifeste scellé sous contrôle strict du rôle steward_admin";
