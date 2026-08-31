-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_commit_oauth_token_refresh                                │
-- │  Commit atomique du jeton d'accès et du jeton de rafraîchissement OAuth│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_commit_oauth_token_refresh($params: object) {
    LET $record_id = $params.record_id;
    LET $expected_refresh_token_enc = $params.expected_refresh_token_enc;
    LET $access_token_enc = $params.access_token_enc;
    LET $token_expires_at = $params.token_expires_at;
    LET $new_refresh_token_enc = $params.new_refresh_token_enc;

    IF $record_id == NONE OR $access_token_enc == NONE OR $token_expires_at == NONE OR $expected_refresh_token_enc == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", "fr", { field: "required parameters missing" });
    };

    LET $updated = UPDATE ONLY $record_id SET
        access_token_enc = $access_token_enc,
        token_expires_at = $token_expires_at,
        refresh_token_enc = IF $new_refresh_token_enc != NONE {
            $new_refresh_token_enc
        } ELSE {
            refresh_token_enc
        },
        updated_at = time::now()
    WHERE refresh_token_enc == $expected_refresh_token_enc;

    RETURN fn::result_ok({
        updated: $updated != NONE,
        record_id: $record_id
    });
} COMMENT "Commit atomique du jeton d'accès et de rafraîchissement OAuth2";
