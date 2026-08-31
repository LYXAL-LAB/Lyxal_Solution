-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_decline_by_token                                            │
-- │  Refus d'une réservation en attente via jeton hôte                      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_decline_by_token($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", "fr", "Le jeton de refus est obligatoire");
    };

    LET $records = SELECT * FROM booking WHERE decline_token = $raw_token OR confirm_token = $raw_token LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", "fr", "Jeton de refus invalide ou expiré");
    };

    LET $b = $records[0];
    UPDATE $b.id SET status = 'declined', updated_at = time::now();

    RETURN {
        id: string::trim(type::string($b.id)),
        event_type_id: string::trim(type::string($b.event_type)),
        start_at: string::trim(type::string($b.start_at)),
        end_at: string::trim(type::string($b.end_at)),
        status: 'declined',
        assigned_resource_id: NONE,
        meeting_url: $b.meeting_url,
        notification_status: NONE,
        calendar_sync_status: NONE,
        guest_name: $b.guest_name,
        guest_email: $b.guest_email
    };
} COMMENT "Refuse une réservation en attente via son jeton hôte direct";
