-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_cancel_booking                                             │
-- │  Annule une réservation existante via son ID ou son jeton unique       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cancel_booking($params: object) {
    LET $id_param = IF $params.booking_id != NONE { $params.booking_id } ELSE { $params.id };
    IF $id_param == NONE {
        THROW "Parameter 'booking_id' is required";
    };

    LET $token_val = string::trim(type::string($id_param));
    LET $bookings = SELECT VALUE id FROM booking 
                     WHERE id = type::record($token_val) OR id = $token_val OR reschedule_token = $token_val LIMIT 1;

    IF array::len($bookings) == 0 {
        THROW "Booking not found";
    };

    LET $target_id = $bookings[0];
    LET $clean_reason = IF $params.reason != NONE { string::trim($params.reason) } ELSE { NONE };

    UPDATE $target_id SET status = 'cancelled', cancellation_reason = $clean_reason, updated_at = time::now();

    DELETE booking_reminder WHERE booking = $target_id AND status = 'pending';

    RETURN {
        booking_id: $target_id,
        cancelled: true
    };
} COMMENT "Annule une réservation de manière sécurisée et détruit les rappels en attente";
