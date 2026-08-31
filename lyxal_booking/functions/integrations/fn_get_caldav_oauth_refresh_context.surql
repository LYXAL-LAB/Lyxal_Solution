-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_caldav_oauth_refresh_context                          │
-- │  Lecture unique du contexte OAuth2 pour le rafraîchissement d'accès    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_caldav_oauth_refresh_context($params: object) {
    LET $record_id = $params.record_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $record_id == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "record_id" });
    };

    LET $source = SELECT id, oauth2_provider, refresh_token_enc FROM ONLY $record_id;
    IF $source == NONE {
        RETURN fn::result_error("BOOKING_NOT_FOUND", $language, { record_id: $record_id });
    };

    LET $auth_id = "booking_setting:auth_config";
    LET $auth = SELECT google_oauth2_client_id, google_oauth2_client_secret FROM ONLY $auth_id;

    RETURN fn::result_ok({
        source_id: $source.id,
        provider: $source.oauth2_provider,
        refresh_token_enc: $source.refresh_token_enc,
        client_id: IF $auth != NONE { $auth.google_oauth2_client_id } ELSE { NONE },
        client_secret_enc: IF $auth != NONE { $auth.google_oauth2_client_secret } ELSE { NONE }
    });
} COMMENT "Lecture unique du contexte OAuth2 pour rafraîchissement de jeton";
