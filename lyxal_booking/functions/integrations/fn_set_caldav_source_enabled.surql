-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_set_caldav_source_enabled                                   │
-- │  Active ou désactive une source de synchronisation CalDAV/EWS           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_set_caldav_source_enabled($params: object) {
    LET $source_id = IF $params.source_id != NONE { $params.source_id } ELSE { $params.id };
    LET $enabled = type::bool($params.enabled);

    IF $source_id == NONE {
        THROW "Parameter 'source_id' is required";
    };

    LET $record_id = type::record(type::string($source_id));

    UPDATE $record_id SET enabled = $enabled, updated_at = time::now();

    RETURN {
        source_id: $record_id,
        enabled: $enabled,
        updated: true
    };
} COMMENT "Active ou désactive une source de calendrier distant";
