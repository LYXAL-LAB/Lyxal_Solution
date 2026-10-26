-- ============================================================================
-- FONCTION : fn::ingestion_dashboard_metrics
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Fournit les métriques et KPIs temps réel pour la console Data Steward
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_dashboard_metrics($params: object) {
    LET $batch_filter = IF $params.batch_id != NONE { <string> $params.batch_id } ELSE { NONE };
    LET $b_rec = IF $batch_filter != NONE { <record> string::concat('ingestion_batch:', $batch_filter) } ELSE { NONE };

    -- Métriques des lots
    LET $batches = (SELECT statut, total_lignes, lignes_verifiees, lignes_a_confirmer, lignes_rejetees FROM ingestion_batch);
    LET $total_batches = array::len($batches);
    LET $batches_active = array::len((SELECT id FROM ingestion_batch WHERE statut IN ["RECEIVED", "PARSING", "VALIDATING"]));
    LET $batches_staged = array::len((SELECT id FROM ingestion_batch WHERE statut = "STAGED"));
    LET $batches_published = array::len((SELECT id FROM ingestion_batch WHERE statut = "PUBLISHED"));
    LET $batches_failed = array::len((SELECT id FROM ingestion_batch WHERE statut = "FAILED"));

    -- Métriques des articles en staging (filtrées par lot si spécifié)
    LET $all_staged = (SELECT qualification, is_approved FROM ingestion_staged_item WHERE ($b_rec == NONE OR batch = $b_rec));
    LET $total_staged = array::len($all_staged);
    LET $verified_items = array::len((SELECT id FROM $all_staged WHERE qualification = "VERIFIED"));
    LET $to_confirm_items = array::len((SELECT id FROM $all_staged WHERE qualification = "TO_CONFIRM"));
    LET $rejected_items = array::len((SELECT id FROM $all_staged WHERE qualification = "REJECTED"));
    LET $approved_items = array::len((SELECT id FROM $all_staged WHERE is_approved = true));

    -- Métriques de quarantaine (filtrées par lot si spécifié)
    LET $all_quarantine = (SELECT severite, is_resolved FROM ingestion_quarantine_record WHERE ($b_rec == NONE OR batch = $b_rec));
    LET $total_quarantine = array::len($all_quarantine);
    LET $quarantine_critical = array::len((SELECT id FROM $all_quarantine WHERE severite = "CRITICAL"));
    LET $quarantine_pending = array::len((SELECT id FROM $all_quarantine WHERE is_resolved != true));

    -- Métriques des manifestes de publication
    LET $manifests = (SELECT statut, is_sealed, items_committed, items_failed FROM ingestion_publication_manifest WHERE ($b_rec == NONE OR batch = $b_rec));
    LET $total_manifests = array::len($manifests);
    LET $sealed_manifests = array::len((SELECT id FROM $manifests WHERE is_sealed = true));
    LET $approved_manifests = array::len((SELECT id FROM $manifests WHERE statut = "APPROVED"));
    LET $committed_manifests = array::len((SELECT id FROM $manifests WHERE statut = "COMMITTED"));

    RETURN fn::result_ok({
        batches: {
            total: $total_batches,
            active: $batches_active,
            staged: $batches_staged,
            published: $batches_published,
            failed: $batches_failed
        },
        items: {
            total: $total_staged,
            verified: $verified_items,
            to_confirm: $to_confirm_items,
            rejected: $rejected_items,
            approved: $approved_items
        },
        quarantine: {
            total: $total_quarantine,
            critical: $quarantine_critical,
            pending: $quarantine_pending
        },
        manifests: {
            total: $total_manifests,
            sealed: $sealed_manifests,
            approved: $approved_manifests,
            committed: $committed_manifests
        }
    });
} COMMENT "Fournit les indicateurs clés d'avancement et de conformité du pipeline pour la console Data Steward";
