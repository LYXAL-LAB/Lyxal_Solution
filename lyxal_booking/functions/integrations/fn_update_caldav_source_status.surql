-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_caldav_source_status                                │
-- │  Mise à jour du statut global d'une source de synchronisation           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_caldav_source_status($params: object) {
    LET $source_id = $params.source_id;
    LET $sync_status = $params.sync_status;
    LET $last_sync_error = $params.last_sync_error;

    IF $source_id == NONE {
        THROW "Parameter 'source_id' is required";
    };

    UPDATE ONLY $source_id SET
        sync_status = $sync_status,
        last_sync_error = $last_sync_error,
        last_synced = time::now();

    RETURN {
        source_id: $source_id,
        updated: true
    };
} COMMENT "Met à jour l'horodatage et le statut global d'une source CalDAV/EWS";
