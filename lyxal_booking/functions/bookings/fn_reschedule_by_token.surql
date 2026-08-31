-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_reschedule_by_token                                         │
-- │  Report de réservation sécurisé via jeton invité                         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_reschedule_by_token($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", "fr", "Le jeton de report est obligatoire");
    };

    LET $records = SELECT * FROM booking WHERE reschedule_token = $raw_token LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", "fr", "Jeton de report invalide ou introuvable");
    };

    LET $b = $records[0];
    LET $new_start = IF $params.new_start_at != NONE { type::datetime($params.new_start_at) } ELSE { NONE };
    LET $new_end = IF $params.new_end_at != NONE { type::datetime($params.new_end_at) } ELSE { NONE };

    IF $new_start == NONE OR $new_end == NONE {
        RETURN fn::result_error("BOOKING_TIMES_REQUIRED", "fr", "Les créneaux de début et fin sont obligatoires");
    };

    UPDATE $b.id SET start_at = $new_start, end_at = $new_end, updated_at = time::now();

    RETURN {
        id: string::trim(type::string($b.id)),
        event_type_id: string::trim(type::string($b.event_type)),
        start_at: string::trim(type::string($new_start)),
        end_at: string::trim(type::string($new_end)),
        status: $b.status,
        assigned_resource_id: NONE,
        meeting_url: $b.meeting_url,
        notification_status: NONE,
        calendar_sync_status: NONE,
        guest_name: $b.guest_name,
        guest_email: $b.guest_email
    };
} COMMENT "Reporte de manière transactionnelle une réservation via son jeton public invité";
