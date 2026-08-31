-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_calendar_sync_state                                 │
-- │  Mise à jour du token de synchronisation propre à un calendrier        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_calendar_sync_state($params: object) {
    LET $source_id = $params.source_id;
    LET $calendar_href = $params.calendar_href;
    LET $sync_state = $params.sync_state;

    IF $source_id == NONE OR $calendar_href == NONE {
        THROW "Parameters 'source_id' and 'calendar_href' are required";
    };

    LET $existing = (SELECT VALUE id FROM ONLY booking_calendar WHERE source == $source_id AND href == $calendar_href).id;

    IF $existing != NONE {
        UPDATE $existing SET sync_state = $sync_state, last_synced_at = time::now();
        RETURN { id: $existing, updated: true };
    } ELSE {
        LET $created = CREATE ONLY booking_calendar CONTENT {
            source: $source_id,
            href: $calendar_href,
            sync_state: $sync_state,
            last_synced_at: time::now()
        };
        RETURN { id: $created.id, created: true };
    };
} COMMENT "Mise à jour du token de synchronisation RFC 6578 rattaché à une collection/calendrier spécifique";
