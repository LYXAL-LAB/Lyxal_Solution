-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ fn::booking_cli_delete_user                                              │
-- │ Suppression atomique contrôlée avec protection du dernier admin         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cli_delete_user($params: object) {
    LET $email = string::lowercase(string::trim($params.email));

    LET $target = (SELECT * FROM booking_account WHERE email = $email LIMIT 1);
    IF array::len($target) == 0 {
        RETURN fn::result_error("BOOKING_USER_NOT_FOUND", "fr", { email: $email });
    };
    LET $acc = $target[0];

    IF $acc.role == "admin" AND $acc.enabled == true {
        LET $active_admins = (SELECT count() FROM booking_account WHERE role = "admin" AND enabled = true GROUP ALL);
        LET $admin_count = IF array::len($active_admins) > 0 { $active_admins[0].count } ELSE { 0 };
        IF $admin_count <= 1 {
            RETURN fn::result_error("BOOKING_CANNOT_DELETE_LAST_ADMIN", "fr", { email: $email });
        };
    };

    LET $avatar_path = $acc.avatar_url;

    -- Purge des sessions actives
    DELETE booking_session WHERE account = $acc.id;

    -- Purge des sources CalDAV exclusivement détenues
    LET $sources = (SELECT id FROM booking_caldav_source WHERE account = $acc.id);
    LET $deleted_sources_count = array::len($sources);
    DELETE booking_caldav_source WHERE account = $acc.id;

    -- Suppression du compte principal
    DELETE $acc.id;

    RETURN fn::result_ok({
        deleted: true,
        account_id: $acc.id,
        email: $acc.email,
        avatar_path: $avatar_path,
        deleted_sources: $deleted_sources_count
    });
};
