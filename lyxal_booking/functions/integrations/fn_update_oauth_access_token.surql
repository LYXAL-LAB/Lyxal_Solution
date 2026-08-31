-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_oauth_access_token                                 │
-- │  Mise à jour atomique (avec support optionnel d'expected_old_value)    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_oauth_access_token($params: object) {
    LET $record_id = $params.record_id;
    LET $new_envelope = $params.access_token_enc;
    LET $token_expires_at = $params.token_expires_at;
    LET $expected_old = $params.expected_old_value;

    IF $record_id == NONE OR $new_envelope == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", "fr", { field: "record_id or access_token_enc" });
    };

    LET $updated = IF $expected_old != NONE {
        UPDATE ONLY $record_id SET
            access_token_enc = $new_envelope,
            token_expires_at = $token_expires_at,
            updated_at = time::now()
        WHERE access_token_enc == $expected_old
    } ELSE {
        UPDATE ONLY $record_id SET
            access_token_enc = $new_envelope,
            token_expires_at = $token_expires_at,
            updated_at = time::now()
    };

    RETURN fn::result_ok({
        updated: $updated != NONE,
        record_id: $record_id
    });
} COMMENT "Mise à jour atomique du jeton d'accès OAuth et horodatage d'expiration sur booking_caldav_source";
