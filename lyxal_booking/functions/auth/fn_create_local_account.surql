-- ============================================================================
-- CREATION ATOMIQUE D'UN COMPTE UTILISATEUR LOCAL
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_create_local_account(
    $params: object
) {
    LET $name = $params.name;
    LET $email = $params.email;
    LET $username = $params.username;
    LET $password_hash = $params.password_hash;
    LET $force_admin = $params.force_admin OR false;
    LET $language = $params.language OR "fr";

    IF $email == NONE OR string::len(string::trim($email)) == 0 {
        RETURN fn::result_error("BOOKING_USERNAME_EMAIL_REQUIRED", $language, { field: "email" });
    };

    LET $clean_email = string::lowercase(string::trim($email));

    -- Contrôle d'unicité e-mail
    LET $existing_email = SELECT id FROM booking_account WHERE email = $clean_email LIMIT 1;
    IF array::len($existing_email) > 0 {
        RETURN fn::result_error("BOOKING_AUTH_EMAIL_ALREADY_EXISTS", $language, { email: $clean_email });
    };

    -- Contrôle d'unicité pseudo
    LET $clean_username = string::lowercase(string::trim($username));
    LET $existing_user = SELECT id FROM booking_account WHERE username = $clean_username LIMIT 1;
    IF array::len($existing_user) > 0 {
        RETURN fn::result_error("BOOKING_AUTH_USERNAME_ALREADY_TAKEN", $language, { username: $clean_username });
    };

    -- Détermination du rôle (premier compte = admin, ou force_admin interne)
    LET $total_accounts = SELECT VALUE count() FROM booking_account;
    LET $role = IF $force_admin OR array::len($total_accounts) == 0 OR $total_accounts[0] == 0 { "admin" } ELSE { "user" };

    LET $now = time::now();
    LET $account = CREATE ONLY booking_account CONTENT {
        name: string::trim($name),
        email: $clean_email,
        username: $clean_username,
        password_hash: $password_hash,
        role: $role,
        timezone: "UTC",
        language: $language,
        enabled: true,
        created_at: $now,
        updated_at: $now
    };

    RETURN fn::result_ok({
        id: $account.id,
        name: $account.name,
        email: $account.email,
        username: $account.username,
        role: $account.role,
        timezone: $account.timezone,
        language: $account.language,
        enabled: $account.enabled
    });
};
