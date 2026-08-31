-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_replace_resource_events                                   │
-- │  Remplacement atomique des événements cachés par clé canonique         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_replace_resource_events($params: object) {
    LET $resource_id = $params.resource_id;
    LET $events = $params.events;
    LET $synced_at = $params.synced_at;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $resource_id == NONE OR $events == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "resource_id or events" });
    };

    -- Suppression des événements orphelins de la ressource non présents dans la nouvelle liste
    DELETE booking_resource_event WHERE resource = $resource_id;

    LET $inserted = 0;

    FOR $e IN $events {
        CREATE booking_resource_event SET
            resource = $resource_id,
            uid = $e.uid,
            recurrence_id = $e.recurrence_id,
            summary = $e.summary,
            start_at = $e.start_at,
            end_at = $e.end_at,
            raw_start_at = $e.raw_start_at,
            raw_end_at = $e.raw_end_at,
            all_day = IF $e.all_day != NONE { $e.all_day } ELSE { false },
            timezone = $e.timezone,
            rrule = $e.rrule,
            raw_ical = $e.raw_ical,
            status = $e.status,
            transp = $e.transp,
            created_at = time::now();
    };

    UPDATE ONLY $resource_id SET
        last_synced_at = IF $synced_at != NONE { $synced_at } ELSE { time::now() },
        last_sync_error = NONE,
        updated_at = time::now();

    RETURN fn::result_ok({
        resource_id: $resource_id,
        inserted: count($events),
        updated: 0,
        deleted: 0
    });
};
