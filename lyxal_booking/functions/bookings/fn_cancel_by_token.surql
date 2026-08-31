-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_cancel_by_token                                            │
-- │  Annulation sécurisée à usage unique via jeton invité                    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cancel_by_token($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", "fr", "Le jeton d'annulation est obligatoire");
    };

    LET $records = SELECT * FROM booking WHERE cancel_token = $raw_token LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", "fr", "Jeton d'annulation invalide ou déjà consommé");
    };

    LET $b = $records[0];
    LET $clean_reason = IF $params.reason != NONE { string::trim($params.reason) } ELSE { NONE };

    UPDATE $b.id SET status = 'cancelled', cancellation_reason = $clean_reason, updated_at = time::now();
    DELETE booking_reminder WHERE booking = $b.id AND status = 'pending';

    RETURN {
        booking_id: string::trim(type::string($b.id)),
        cancelled: true
    };
} COMMENT "Annule de manière transactionnelle une réservation via son jeton public invité";
