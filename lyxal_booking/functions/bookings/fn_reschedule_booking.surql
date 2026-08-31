-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_reschedule_booking                                        │
-- │  Reprogramme un rendez-vous vers une nouvelle plage horaire            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_reschedule_booking($params: object) {
    LET $id_param = IF $params.booking_id != NONE { $params.booking_id } ELSE { $params.reschedule_token };
    IF $id_param == NONE {
        THROW "Parameter 'booking_id' is required";
    };

    LET $token_val = string::trim(type::string($id_param));
    LET $new_start_at = type::datetime($params.new_start_at);
    LET $new_end_at = type::datetime($params.new_end_at);

    IF $new_end_at <= $new_start_at {
        THROW "Parameter 'new_end_at' must be strictly after 'new_start_at'";
    };

    LET $bookings = SELECT VALUE id FROM booking 
                     WHERE id = type::record($token_val) OR id = $token_val OR reschedule_token = $token_val LIMIT 1;

    IF array::len($bookings) == 0 {
        THROW "Booking not found";
    };

    LET $target_id = $bookings[0];

    UPDATE $target_id MERGE {
        start_at: $new_start_at,
        end_at: $new_end_at,
        status: 'rescheduled',
        updated_at: time::now()
    };

    DELETE booking_reminder WHERE booking = $target_id AND status = 'pending';

    LET $rem_24h = $new_start_at - 24h;
    LET $rem_1h = $new_start_at - 1h;

    IF $rem_24h > time::now() {
        CREATE booking_reminder CONTENT {
            booking: $target_id,
            reminder_type: 'email',
            scheduled_at: $rem_24h,
            status: 'pending',
            created_at: time::now()
        };
    };
    IF $rem_1h > time::now() {
        CREATE booking_reminder CONTENT {
            booking: $target_id,
            reminder_type: 'email',
            scheduled_at: $rem_1h,
            status: 'pending',
            created_at: time::now()
        };
    };

    RETURN {
        booking_id: $target_id,
        rescheduled: true
    };
} COMMENT "Reprogramme un rendez-vous vers un nouveau créneau et recalcule les rappels";
