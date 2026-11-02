-- ============================================================================
-- EVENTS : lyxal_pipeline_ingestion
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Déclencheurs événementiels officiels vers le bus lyxal_event
-- ============================================================================

DEFINE EVENT IF NOT EXISTS ingestion_batch_completed_event ON TABLE ingestion_batch 
WHEN $event = "UPDATE" AND $after.statut = "Completed" AND $before.statut != "Completed" 
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "ingestion.batch.completed",
        producer: "lyxal_pipeline_ingestion",
        payload: {
            batch_id: <string> $after.id,
            fournisseur_id: $after.fournisseur_id,
            total_lignes: $after.total_lignes,
            lignes_verifiees: $after.lignes_verifiees,
            lignes_a_confirmer: $after.lignes_a_confirmer,
            lignes_rejetees: $after.lignes_rejetees
        },
        metadata: {
            source_type: $after.source_type,
            file_hash: $after.file_hash_blake3
        }
    });
    -- Une publication refusée fait échouer la mutation au lieu d'être perdue
    IF !$published.ok { THROW $published.error.code; };
};

DEFINE EVENT IF NOT EXISTS ingestion_manifest_approved_event ON TABLE ingestion_publication_manifest 
WHEN $event = "UPDATE" AND $after.statut = "Approved" AND $before.statut != "Approved" 
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
