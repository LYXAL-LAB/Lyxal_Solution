-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_confirm_pending                                           │
-- │  Approuve manuellement une réservation depuis le dashboard hôte         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_confirm_pending($params: object) {
    LET $id_param = IF $params.booking_id != NONE { $params.booking_id } ELSE { $params.id };
    IF $id_param == NONE {
        RETURN fn::result_error("BOOKING_ID_REQUIRED", "fr", "Le paramètre 'booking_id' est obligatoire");
    };

    LET $token_val = string::trim(type::string($id_param));
    LET $bookings = SELECT * FROM booking WHERE id = type::record($token_val) OR id = $token_val LIMIT 1;
    IF array::len($bookings) == 0 {
        RETURN fn::result_error("BOOKING_NOT_FOUND", "fr", "Réservation introuvable");
    };

    LET $b = $bookings[0];
    UPDATE $b.id SET status = 'confirmed', updated_at = time::now();

    RETURN {
        id: string::trim(type::string($b.id)),
        event_type_id: string::trim(type::string($b.event_type)),
        start_at: string::trim(type::string($b.start_at)),
        end_at: string::trim(type::string($b.end_at)),
        status: 'confirmed',
        assigned_resource_id: NONE,
        meeting_url: $b.meeting_url,
        notification_status: NONE,
        calendar_sync_status: NONE,
        guest_name: $b.guest_name,
        guest_email: $b.guest_email
    };
} COMMENT "Approuve manuellement une réservation en attente depuis le dashboard hôte";
