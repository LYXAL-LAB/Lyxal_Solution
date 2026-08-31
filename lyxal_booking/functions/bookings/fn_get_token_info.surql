-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_token_info                                             │
-- │  Valide un jeton public et retourne les informations de réservation     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_token_info($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", "fr", "Le jeton d'accès est obligatoire");
    };

    LET $records = SELECT * FROM booking WHERE cancel_token = $raw_token OR reschedule_token = $raw_token OR confirm_token = $raw_token OR decline_token = $raw_token LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", "fr", "Jeton d'accès invalide ou introuvable");
    };

    LET $b = $records[0];
    LET $action = IF $b.cancel_token == $raw_token { "guest_cancel" }
                  ELSE IF $b.reschedule_token == $raw_token { "guest_reschedule" }
                  ELSE IF $b.confirm_token == $raw_token { "host_approve" }
                  ELSE { "host_decline" };

    RETURN {
        action: $action,
        booking_id: string::trim(type::string($b.id)),
        guest_name: $b.guest_name,
        guest_email: $b.guest_email,
        start_at: string::trim(type::string($b.start_at)),
        end_at: string::trim(type::string($b.end_at)),
        event_type_title: IF $b.event_type != NONE { string::trim(type::string($b.event_type)) } ELSE { "Réservation" },
        expires_at: string::trim(type::string($b.start_at)),
        is_valid: $b.status != 'cancelled'
    };
} COMMENT "Extrait et valide les métadonnées d'un jeton public sans effectuer de mutation";
