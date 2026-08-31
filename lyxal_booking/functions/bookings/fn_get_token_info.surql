-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_token_info                                             │
-- │  Valide un jeton public et retourne les informations de réservation     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_token_info($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", $language, { field: "token" });
    };

    LET $records = SELECT * FROM booking WHERE cancel_token = $raw_token OR reschedule_token = $raw_token OR confirm_token = $raw_token OR decline_token = $raw_token LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", $language, { token: $raw_token });
    };

    LET $b = $records[0];
    LET $action = IF $b.cancel_token == $raw_token { "guest_cancel" }
                  ELSE IF $b.reschedule_token == $raw_token { "guest_reschedule" }
                  ELSE IF $b.confirm_token == $raw_token { "host_approve" }
                  ELSE { "host_decline" };

    RETURN fn::result_ok({
        action: $action,
        booking_id: $b.id,
        status: $b.status,
        guest_name: $b.guest_name,
        guest_email: $b.guest_email,
        start_at: $b.start_at,
        end_at: $b.end_at,
        event_type_title: IF $b.event_type != NONE { string::trim(type::string($b.event_type)) } ELSE { "Réservation" },
        expires_at: $b.start_at,
        is_valid: $b.status != 'cancelled'
    });
} COMMENT "Extrait et valide les métadonnées d'un jeton public sans effectuer de mutation";
