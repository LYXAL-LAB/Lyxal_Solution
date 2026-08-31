-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_setting_secret                                     │
-- │  Mise à jour atomique conditionnelle d'un secret chiffré dans setting   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_setting_secret($params: object) {
    LET $record_id = $params.record_id;
    LET $expected_old = $params.expected_old_value;
    LET $new_envelope = $params.new_envelope;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $record_id == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "record_id" });
    };

    IF $expected_old == NONE {
        RETURN fn::result_error("BOOKING_SECRET_EXPECTED_VALUE_REQUIRED", $language, { field: "expected_old_value" });
    };

    IF $new_envelope == NONE OR !string::starts_with($new_envelope, "enc:") {
        RETURN fn::result_error("BOOKING_SECRET_ENVELOPE_INVALID", $language, { field: "new_envelope" });
    };

    LET $updated = UPDATE ONLY $record_id SET
        value = $new_envelope,
        updated_at = time::now()
    WHERE value == $expected_old;

    RETURN fn::result_ok({
        updated: $updated != NONE,
        record_id: $record_id
    });
} COMMENT "Mise à jour atomique conditionnelle d'un secret chiffré dans booking_setting";
