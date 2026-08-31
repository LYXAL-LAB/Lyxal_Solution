-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_approve_by_token                                            │
-- │  Approbation d'une réservation en attente via jeton hôte                │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_approve_by_token($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", "fr", "Le jeton d'approbation est obligatoire");
    };

    LET $records = SELECT * FROM booking WHERE confirm_token = $raw_token OR token = $raw_token LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", "fr", "Jeton d'approbation invalide ou expiré");
    };

    LET $b = $records[0];
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
} COMMENT "Approuve une réservation en attente via son jeton hôte direct";
