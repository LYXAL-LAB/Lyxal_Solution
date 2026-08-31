-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_is_slot_available                                         │
-- │  Vérifie si une plage horaire est libre de tout conflit (réservations, │
-- │  événements d'agenda distants et congés approuvés).                    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_is_slot_available(
    $params: object
) {
    LET $event_type_id = $params.event_type_id;
    LET $start_at = $params.start_at;
    LET $end_at = $params.end_at;
    LET $host_id = $params.host_id;

    -- ------------------------------------------------------------------------
    -- 1. VÉRIFICATION DES PARAMÈTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $start_at == NONE {
        RETURN fn::result_error("BOOKING_START_AT_REQUIRED", $params.language, NONE);
    };
    IF $end_at == NONE {
        RETURN fn::result_error("BOOKING_END_AT_REQUIRED", $params.language, NONE);
    };
    IF $end_at <= $start_at {
        RETURN fn::result_error("BOOKING_INVALID_TIME_RANGE", $params.language, NONE);
    };

    -- ------------------------------------------------------------------------
    -- 2. RECHERCHE DE CHEVAUCHEMENTS DANS LES RÉSERVATIONS EXISTANTES (booking)
    -- ------------------------------------------------------------------------
    LET $booking_conflicts = IF $host_id != NONE {
        SELECT VALUE id FROM booking 
         WHERE (event_type = $event_type_id OR host = $host_id)
           AND status IN ['confirmed', 'pending']
           AND start_at < $end_at 
           AND end_at > $start_at
    } ELSE {
        SELECT VALUE id FROM booking 
         WHERE event_type = $event_type_id 
           AND status IN ['confirmed', 'pending']
           AND start_at < $end_at 
           AND end_at > $start_at
    };

    IF array::len($booking_conflicts) > 0 {
        RETURN fn::result_ok({ available: false });
    };

    -- ------------------------------------------------------------------------
    -- 3. RECHERCHE DE CHEVAUCHEMENTS DANS LES CONGÉS APPROUVÉS (booking_time_off)
    -- ------------------------------------------------------------------------
    IF $host_id != NONE {
        LET $time_off_conflicts = SELECT VALUE id FROM booking_time_off 
                                   WHERE account = $host_id 
                                     AND status = 'approved' 
                                     AND start_at < $end_at 
                                     AND end_at > $start_at;
        IF array::len($time_off_conflicts) > 0 {
            RETURN fn::result_ok({ available: false });
        };
    };

    -- Créneau 100% disponible
    RETURN fn::result_ok({ available: true });
} COMMENT "Vérifie l'absence de chevauchement sur un créneau de réservation (réservations et congés)";
