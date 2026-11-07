-- ============================================================================
-- EVENTS : lyxal_pipeline_ingestion
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Déclencheurs événementiels officiels vers le bus lyxal_event
-- ============================================================================
-- Chaque événement est émis par la base sur la transition d'état qui le motive, dans la même
-- transaction que cette transition (.agents/AGENTS.md §5.6.1) : l'état et l'événement ne peuvent
-- pas diverger. Une publication refusée fait échouer la transition au lieu d'être perdue. Les
-- charges utiles sont celles des structures Rust de src/events.rs.

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

DEFINE EVENT OVERWRITE ingestion_batch_staged_event ON TABLE ingestion_batch
WHEN $event = "UPDATE" AND $after.statut = "STAGED" AND $before.statut != "STAGED"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "ingestion.batch.staged",
        producer: "lyxal_pipeline_ingestion",
        payload: {
            batch_id: <string> $after.id,
            source_type: $after.source_type,
            total_lignes: $after.total_lignes,
            verified_count: $after.lignes_verifiees,
            to_confirm_count: $after.lignes_a_confirmer,
            rejected_count: $after.lignes_rejetees
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE ingestion_batch_failed_event ON TABLE ingestion_batch
WHEN $event = "UPDATE" AND $after.statut = "FAILED" AND $before.statut != "FAILED"
THEN {
    LET $transition = array::last($after.transitions);
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "ingestion.batch.failed",
        producer: "lyxal_pipeline_ingestion",
        payload: {
            batch_id: <string> $after.id,
            error_code: $transition.error_code,
            message: $transition.reason
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT OVERWRITE ingestion_manifest_published_event ON TABLE ingestion_publication_manifest
WHEN $event = "UPDATE" AND $after.statut = "COMMITTED" AND $before.statut != "COMMITTED"
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "ingestion.manifest.published",
        producer: "lyxal_pipeline_ingestion",
        payload: {
            manifest_ref: $after.manifest_ref,
            batch_id: <string> $after.batch,
            items_committed: $after.items_committed,
            items_failed: $after.items_failed,
            publisher_agent: array::last($after.transitions).triggered_by
        },
        metadata: {
            manifest_version: $after.manifest_version
        }
    });
    IF !$published.ok { THROW $published.error.code; };
};
