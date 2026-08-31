-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_user_caldav_sources                                   â”‚
-- â”‚  RÃ©cupÃ¨re toutes les sources de calendriers distants d'un compte hÃ´te   â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_user_caldav_sources(
    $account_id: option<record<booking_account>>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    RETURN SELECT id, provider, url, username, last_synced, sync_status, last_sync_error, created_at
             FROM booking_caldav_source
            WHERE account = $account_id
            ORDER BY created_at ASC;
} COMMENT "RÃ©cupÃ¨re toutes les sources de calendriers distants configurÃ©es par un compte utilisateur";
