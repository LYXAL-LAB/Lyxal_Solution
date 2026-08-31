-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_caldav_refresh_token                               │
-- │  Mise à jour atomique conditionnelle du jeton de rafraîchissement OAuth│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_caldav_refresh_token($params: object) {
    LET $record_id = $params.record_id;
    LET $expected_old = $params.expected_old_value;
    LET $new_envelope = $params.new_envelope;

    IF $record_id == NONE OR $new_envelope == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", "fr", { field: "record_id or new_envelope" });
    };

    IF $expected_old == NONE {
        RETURN fn::result_error("BOOKING_SECRET_EXPECTED_VALUE_REQUIRED", "fr", { field: "expected_old_value" });
    };

    LET $updated = UPDATE ONLY $record_id SET
        refresh_token_enc = $new_envelope,
        updated_at = time::now()
    WHERE refresh_token_enc == $expected_old;

    RETURN fn::result_ok({
        updated: $updated != NONE,
        record_id: $record_id
    });
} COMMENT "Mise à jour atomique et sécurisée du jeton de rafraîchissement OAuth sur booking_caldav_source";
