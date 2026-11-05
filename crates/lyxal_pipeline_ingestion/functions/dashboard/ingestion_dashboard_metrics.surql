-- ============================================================================
-- FONCTION : fn::ingestion_dashboard_metrics
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Indicateurs du pipeline pour la console Data Steward
-- APPEL    : externe (console Data Steward), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_dashboard_metrics($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $b = $report.value.batch_id;

    LET $batches = (SELECT VALUE statut FROM ingestion_batch WHERE $b == NONE OR id = $b);
    LET $items = (SELECT qualification, is_approved FROM ingestion_staged_item WHERE $b == NONE OR batch = $b);
    LET $quarantine = (SELECT severite, is_resolved FROM ingestion_quarantine_record WHERE $b == NONE OR batch = $b);
    LET $manifests = (SELECT statut, is_sealed FROM ingestion_publication_manifest WHERE $b == NONE OR batch = $b);

    RETURN fn::result_ok({
        batches: {
            total: count($batches),
            active: count($batches[WHERE $this IN ["RECEIVED", "PARSING", "VALIDATING"]]),
            staged: count($batches[WHERE $this = "STAGED"]),
            published: count($batches[WHERE $this = "PUBLISHED"]),
            failed: count($batches[WHERE $this = "FAILED"])
        },
        items: {
            total: count($items),
            verified: count($items[WHERE qualification = "VERIFIED"]),
            to_confirm: count($items[WHERE qualification = "TO_CONFIRM"]),
            rejected: count($items[WHERE qualification = "REJECTED"]),
            approved: count($items[WHERE is_approved = true])
        },
        quarantine: {
            total: count($quarantine),
            critical: count($quarantine[WHERE severite = "CRITICAL"]),
            pending: count($quarantine[WHERE is_resolved != true])
        },
        manifests: {
            total: count($manifests),
            sealed: count($manifests[WHERE is_sealed = true]),
            approved: count($manifests[WHERE statut = "APPROVED"]),
            committed: count($manifests[WHERE statut = "COMMITTED"])
        }
    });
} COMMENT "Fournit les indicateurs d'avancement et de conformité du pipeline (lots, articles, quarantaine, manifestes), pour un lot ou pour l'ensemble";
