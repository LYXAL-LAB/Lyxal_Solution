-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_replace_synchronized_calendar_snapshot                    │
-- │  Full Sync transactionnel atomique : upsert, nettoyage d'orphelins & token│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_replace_synchronized_calendar_snapshot($params: object) {
    LET $source_id = $params.source_id;
    LET $calendar_id = $params.calendar_id;
    LET $events = IF $params.events != NONE { $params.events } ELSE { [] };
    LET $sync_state = $params.sync_state;

    IF $source_id == NONE OR $calendar_id == NONE {
        THROW "Parameters 'source_id' and 'calendar_id' are required";
    };

    -- 1. Upsert atomique de tous les événements distants transmis
    FOR $ev IN $events {
        LET $existing = (SELECT VALUE id FROM ONLY booking_event WHERE source == $source_id AND calendar_id == $calendar_id AND remote_id == $ev.remote_id).id;
        IF $existing != NONE {
            UPDATE $existing SET ical = $ev.ical, updated_at = time::now();
        } ELSE {
            CREATE booking_event CONTENT {
                source: $source_id,
                calendar_id: $calendar_id,
                remote_id: $ev.remote_id,
                ical: $ev.ical,
                created_at: time::now(),
                updated_at: time::now()
            };
        };
    };

    -- 2. Extraction des remote_id valides du snapshot
    LET $valid_remote_ids = SELECT VALUE remote_id FROM $events;

    -- 3. Suppression atomique des événements orphelins
    LET $deleted = DELETE booking_event WHERE source == $source_id AND calendar_id == $calendar_id AND remote_id NOT IN $valid_remote_ids;

    -- 4. Mise à jour du token de synchronisation dans booking_calendar
    LET $cal_record = (SELECT VALUE id FROM ONLY booking_calendar WHERE source == $source_id AND href == $calendar_id).id;
    IF $cal_record != NONE {
        UPDATE $cal_record SET sync_state = $sync_state, last_synced_at = time::now();
    } ELSE {
        CREATE booking_calendar CONTENT {
            source: $source_id,
            href: $calendar_id,
            sync_state: $sync_state,
            last_synced_at: time::now()
        };
    };

    RETURN {
        events_processed: count($events),
        orphans_deleted: count($deleted),
        synced: true
    };
} COMMENT "Effectue le Full Sync atomique (upsert, suppression des orphelins et persistance du token)";
