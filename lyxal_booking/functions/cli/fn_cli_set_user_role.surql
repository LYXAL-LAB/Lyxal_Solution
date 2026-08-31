-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ fn::booking_cli_set_user_role                                            │
-- │ Promotion/Rétrogradation de rôle avec protection du dernier admin       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cli_set_user_role($params: object) {
    LET $email = string::lowercase(string::trim($params.email));
    LET $new_role = string::lowercase(string::trim($params.role));

    LET $target = (SELECT * FROM booking_account WHERE email = $email LIMIT 1);
    IF array::len($target) == 0 {
        RETURN fn::result_error("BOOKING_USER_NOT_FOUND", "fr", { email: $email });
    };
    LET $acc = $target[0];

    IF $acc.role == "admin" AND $new_role != "admin" AND $acc.enabled == true {
        LET $active_admins = (SELECT count() FROM booking_account WHERE role = "admin" AND enabled = true GROUP ALL);
        LET $admin_count = IF array::len($active_admins) > 0 { $active_admins[0].count } ELSE { 0 };
        IF $admin_count <= 1 {
            RETURN fn::result_error("BOOKING_CANNOT_DEMOTE_LAST_ADMIN", "fr", { email: $email });
        };
    };

    LET $updated = (UPDATE ONLY $acc.id SET role = $new_role, updated_at = time::now());

    RETURN fn::result_ok({
        account_id: $updated.id,
        email: $updated.email,
        role: $updated.role
    });
};
