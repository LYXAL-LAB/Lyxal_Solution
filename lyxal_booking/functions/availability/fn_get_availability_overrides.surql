-- ============================================================================
-- LYXAL OS — BOOKING AVAILABILITY OVERRIDES
-- ============================================================================
-- Fichier  : functions/availability/fn_get_availability_overrides.surql
-- Fonction : fn::booking_get_availability_overrides
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_availability_overrides($params: object) {
    LET $user_id = $params.user_id;

    LET $overrides = SELECT * FROM booking_availability_override WHERE owner_user_id = $user_id ORDER BY date ASC;

    RETURN array::map($overrides, |$o| {
        id: string::concat("", $o.id),
        date: $o.date,
        unavailable: $o.unavailable,
        start_time: $o.start_time,
        end_time: $o.end_time
    });
};
