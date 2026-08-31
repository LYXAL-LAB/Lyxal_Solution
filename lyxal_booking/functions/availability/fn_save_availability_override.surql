-- ============================================================================
-- LYXAL OS — BOOKING AVAILABILITY OVERRIDES
-- ============================================================================
-- Fichier  : functions/availability/fn_save_availability_override.surql
-- Fonction : fn::booking_save_availability_override
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_save_availability_override($params: object) {
    LET $user_id = $params.user_id;
    LET $date = $params.date;
    LET $unavailable = IF $params.unavailable != NONE { $params.unavailable } ELSE { false };
    LET $start_time = $params.start_time;
    LET $end_time = $params.end_time;

    IF $date IS NONE OR string::len(string::trim($date)) = 0 {
        THROW "BOOKING_INVALID_PARAMS: date est obligatoire (format YYYY-MM-DD)";
    };

    LET $record_id = type::thing("booking_availability_override", string::concat($user_id, "_", $date));

    UPSERT ONLY $record_id CONTENT {
        owner_user_id: $user_id,
        date: $date,
        unavailable: $unavailable,
        start_time: $start_time,
        end_time: $end_time,
        updated_at: time::now()
    };

    RETURN {
        id: string::concat("", $record_id),
        date: $date,
        unavailable: $unavailable,
        start_time: $start_time,
        end_time: $end_time
    };
};
