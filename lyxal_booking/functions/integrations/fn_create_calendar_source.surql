-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_caldav_source                                       │
-- │  Ajoute une nouvelle source de synchronisation distante (CalDAV/OAuth)  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_caldav_source($params: object) {
    LET $account_id = $params.account_id;
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    LET $provider = IF $params.provider != NONE { string::lowercase(string::trim($params.provider)) } ELSE { 'caldav' };
    IF $provider NOT IN ['caldav', 'google', 'ews', 'icloud'] {
        THROW "Provider must be one of: 'caldav', 'google', 'ews', 'icloud'";
    };

    LET $auth_kind = IF $params.auth_kind != NONE { string::lowercase(string::trim($params.auth_kind)) } ELSE { 'basic' };
    IF $auth_kind NOT IN ['basic', 'oauth2'] {
        THROW "Auth kind must be one of: 'basic', 'oauth2'";
    };

    LET $url = IF $params.url != NONE { string::trim($params.url) } ELSE { NONE };
    LET $username = IF $params.username != NONE { string::trim($params.username) } ELSE { NONE };
    LET $password_enc = IF $params.password_enc != NONE { string::trim($params.password_enc) } ELSE { NONE };

    IF $auth_kind == 'basic' AND ($password_enc == NONE OR !string::starts_with($password_enc, 'enc:')) {
        THROW "Encrypted password starting with 'enc:' is required for basic auth";
    };

    LET $access_token = IF $params.access_token != NONE { string::trim($params.access_token) } ELSE { NONE };
    LET $refresh_token = IF $params.refresh_token != NONE { string::trim($params.refresh_token) } ELSE { NONE };
    LET $custom_id = $params.id;

    LET $initial_sync_status = IF $auth_kind == 'oauth2' AND $access_token == NONE { 'pending_oauth' } ELSE { 'idle' };

    LET $created = IF $custom_id != NONE {
        UPSERT ONLY $custom_id CONTENT {
            account: $account_id,
            provider: $provider,
            auth_kind: $auth_kind,
            url: $url,
            username: $username,
            password: IF $auth_kind == 'basic' { $password_enc } ELSE { NONE },
            access_token: $access_token,
            refresh_token: $refresh_token,
            sync_status: $initial_sync_status,
            created_at: time::now()
        }
    } ELSE {
        CREATE ONLY booking_caldav_source CONTENT {
            account: $account_id,
            provider: $provider,
            auth_kind: $auth_kind,
            url: $url,
            username: $username,
            password: IF $auth_kind == 'basic' { $password_enc } ELSE { NONE },
            access_token: $access_token,
            refresh_token: $refresh_token,
            sync_status: $initial_sync_status,
            created_at: time::now()
        }
    };

    RETURN {
        id: $created.id,
        created: true
    };
} COMMENT "Ajoute une source de calendrier distant pour la synchronisation (CalDAV/Google/EWS/iCloud)";
