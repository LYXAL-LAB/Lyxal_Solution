-- ============================================================================
-- EVENTS : lyxal_pipeline_ingestion
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Déclencheurs événementiels officiels vers le bus lyxal_event
-- ============================================================================
-- Les autres événements du pipeline (ingestion.batch.staged, ingestion.batch.failed,
-- ingestion.manifest.published) sont publiés par le worker Rust (src/events.rs).

DEFINE EVENT OVERWRITE ingestion_manifest_approved_event ON TABLE ingestion_publication_manifest
WHEN $event = "UPDATE" AND $after.statut = "APPROVED" AND $before.statut != "APPROVED"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "ingestion.manifest.approved",
        producer: "lyxal_pipeline_ingestion",
        payload: {
            manifest_ref: $after.manifest_ref,
            batch_id: <string> $after.batch,
            approved_by: $after.approved_by,
            seal_hash: $after.seal_hash
        },
        metadata: {
            manifest_version: $after.manifest_version
        }
    });
    -- Une publication refusée fait échouer la mutation au lieu d'être perdue
    IF !$published.ok { THROW $published.error.code; };
};
