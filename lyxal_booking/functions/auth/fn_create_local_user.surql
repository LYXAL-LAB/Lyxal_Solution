-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_create_local_user                                         â”‚
-- â”‚  Inscrit un utilisateur local avec calcul atomique du rÃ´le admin/member  â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_create_local_user(
    $name: option<string>,
    $email: option<string>,
    $username: option<string>,
    $password_hash: option<string>,
    $force_admin: option<bool>
) {
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        THROW "Parameter 'name' is required";
    };
    IF $email == NONE OR string::len(string::trim($email)) == 0 {
        THROW "Parameter 'email' is required";
    };

    LET $clean_name = string::trim($name);
    LET $clean_email = string::lowercase(string::trim($email));

    -- ContrÃ´le d'unicitÃ© e-mail
    LET $existing = SELECT VALUE id FROM booking_account WHERE email = $clean_email LIMIT 1;
    IF array::len($existing) > 0 {
        THROW "An account with this email address already exists";
    };

    LET $uname = IF $username != NONE AND string::len(string::trim($username)) > 0 {
        string::lowercase(string::trim($username))
    } ELSE {
        fn::booking_generate_username($clean_email)
    };

    LET $is_forced = IF $force_admin != NONE { $force_admin } ELSE { false };
    LET $total_users = SELECT VALUE count() FROM booking_account;
    LET $assigned_role = IF $is_forced OR (array::len($total_users) > 0 AND $total_users[0] == 0) {
        'admin'
    } ELSE {
        'member'
    };

    CREATE ONLY booking_account CONTENT {
        name: $clean_name,
        email: $clean_email,
        username: $uname,
        password_hash: $password_hash,
        role: $assigned_role,
        timezone: 'UTC',
        language: 'fr',
        enabled: true,
        created_at: time::now()
    };

    RETURN $assigned_role;
} COMMENT "CrÃ©e un compte local avec dÃ©termination atomique du rÃ´le (premier inscrit = admin)";
