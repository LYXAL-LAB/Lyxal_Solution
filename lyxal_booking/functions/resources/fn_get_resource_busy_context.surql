-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_resource_busy_context                                 │
-- │  Lecture des événements ICS cachés et réservations internes confirmées │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_resource_busy_context($params: object) {
    LET $resource_id = $params.resource_id;
    LET $start_at = $params.start_at;
    LET $end_at = $params.end_at;
    LET $exclude_booking_id = $params.exclude_booking_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $resource_id == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "resource_id" });
    };

    -- 1. Événements ICS cachés de la ressource (statut non annulé)
    LET $cached_events = SELECT uid, recurrence_id, raw_start_at, raw_end_at, timezone, rrule, raw_ical, status, transp, all_day
        FROM booking_resource_event
        WHERE resource = $resource_id AND (status == NONE OR string::lowercase(status) != 'cancelled');

    -- 2. Réservations internes confirmées affectées à cette ressource
    LET $confirmed_bookings = IF $exclude_booking_id != NONE {
        SELECT id AS booking_id, start_at, end_at
            FROM booking
            WHERE assigned_resource_id == $resource_id
              AND id != $exclude_booking_id
              AND (status == NONE OR string::lowercase(status) NOT IN ['cancelled', 'rejected']);
    } ELSE {
        SELECT id AS booking_id, start_at, end_at
            FROM booking
            WHERE assigned_resource_id == $resource_id
              AND (status == NONE OR string::lowercase(status) NOT IN ['cancelled', 'rejected']);
    };

    RETURN fn::result_ok({
        cached_events: $cached_events,
        confirmed_bookings: $confirmed_bookings
    });
} COMMENT "Lecture des événements ICS et réservations confirmées pour calcul d'indisponibilité ressource";
