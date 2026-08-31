-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_cancel_by_token                                            │
-- │  Annulation sécurisée à usage unique via jeton invité                    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cancel_by_token($params: object) {
    LET $raw_token = IF $params.token != NONE { string::trim($params.token) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $raw_token == NONE {
        RETURN fn::result_error("BOOKING_TOKEN_REQUIRED", $language, { field: "token" });
    };

    LET $records = SELECT * FROM booking WHERE cancel_token = $raw_token AND status != 'cancelled' LIMIT 1;
    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_TOKEN_INVALID", $language, { token: $raw_token });
    };

    LET $b = $records[0];
    LET $clean_reason = IF $params.reason != NONE { string::trim($params.reason) } ELSE { NONE };

    UPDATE $b.id SET status = 'cancelled', cancel_token = NONE, reschedule_token = NONE, cancellation_reason = $clean_reason, updated_at = time::now();
    DELETE booking_reminder WHERE booking = $b.id AND status = 'pending';

    RETURN fn::result_ok({
        booking_id: $b.id,
        cancelled: true
    });
} COMMENT "Annule de manière transactionnelle une réservation via son jeton public invité";
