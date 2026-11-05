-- ============================================================================
-- FONCTION : fn::ingestion_manifest_approve
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Approbation formelle du manifeste de publication par le Data Steward
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_manifest_approve($params: object) {
    LET $manifest_ref = <string> $params.manifest_ref;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    -- Habilitation : identité lue dans la session (jamais dans les paramètres)
    LET $who = fn::ingestion_session_identity({});
    IF $who.role NOT IN ["steward_admin", "system"] {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $language, {
            manifest_ref: $manifest_ref,
            role: $who.role,
            expected_role: "steward_admin"
        });
    };

    -- Justification obligatoire (10 caractères au moins), contrôlée par lyxal_core
    LET $justif = fn::validation_required_string($params.justification, 10, 2000);
    IF !$justif.valid {
        RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $language, { field: "justification", reason: $justif.code, min_required: 10 });
    };
    LET $justification = $justif.value;

    LET $manifests = (SELECT * FROM ingestion_publication_manifest WHERE manifest_ref = $manifest_ref);
    IF array::len($manifests) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_NOT_FOUND", $language, { manifest_ref: $manifest_ref });
    };

    LET $manif = $manifests[0];

    -- Vérification du scellement
    IF $manif.is_sealed != true OR string::len($manif.seal_hash) == 0 {
        RETURN fn::error_result("INGESTION_MANIFEST_UNSEALED", $language, { manifest_ref: $manifest_ref });
    };

    LET $now = time::now();
    LET $trans = {
        from_state: $manif.statut,
        to_state: "APPROVED",
        triggered_by: $who.operator,
        reason: $justification,
        transitioned_at: $now
    };

    LET $updated = (UPDATE ONLY $manif.id SET
        statut = "APPROVED",
        approved_by = $who.operator,
        approver_role = $who.role,
        approved_at = $now,
        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]));
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $language, { table: "ingestion_publication_manifest" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Approuve un manifeste scellé ; l'approbateur (steward_admin, ou session système) est lu dans la session, jamais dans les paramètres"
PERMISSIONS WHERE $token != NONE OR $auth != NONE;
