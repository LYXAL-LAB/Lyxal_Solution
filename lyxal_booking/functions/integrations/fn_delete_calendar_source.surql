-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_delete_caldav_source                                       │
-- │  Déconnecte et supprime une source de calendrier distant et ses journaux │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_delete_caldav_source($params: object) {
    LET $source_id = IF $params.source_id != NONE { $params.source_id } ELSE { $params.id };
    IF $source_id == NONE {
        THROW "Parameter 'source_id' is required";
    };

    LET $record_id = type::record(type::string($source_id));

    DELETE booking_sync_log WHERE source = $record_id;
    DELETE booking_calendar WHERE source = $record_id;
    DELETE $record_id;

    RETURN {
        source_id: $record_id,
        deleted: true
    };
} COMMENT "Supprime une source de synchronisation CalDAV/Google et ses journaux associés";
