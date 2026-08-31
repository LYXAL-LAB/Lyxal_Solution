-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_create_user                                                â”‚
-- â”‚  Inscrit et crÃ©e un nouveau compte utilisateur                          â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_create_user(
    $name: option<string>,
    $email: option<string>,
    $username: option<string>,
    $password_hash: option<string>,
    $role: option<string>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        THROW "Parameter 'name' is required";
    };
    IF $email == NONE OR string::len(string::trim($email)) == 0 {
        THROW "Parameter 'email' is required";
    };

    LET $clean_name = string::trim($name);
    LET $clean_email = string::lowercase(string::trim($email));

    -- ContrÃ´le d'unicitÃ© de l'e-mail
    LET $existing = SELECT VALUE id FROM booking_account WHERE email = $clean_email LIMIT 1;
    IF array::len($existing) > 0 {
        THROW "An account with this email address already exists";
    };

    LET $clean_uname = IF $username != NONE AND string::len(string::trim($username)) > 0 {
        string::lowercase(string::trim($username))
    } ELSE {
        NONE
    };

    LET $clean_role = IF $role != NONE { string::lowercase(string::trim($role)) } ELSE { 'member' };
    IF $clean_role NOT IN ['admin', 'member'] {
        THROW "Role must be 'admin' or 'member'";
    };

    -- ------------------------------------------------------------------------
    -- 2. CRÃ‰ATION DU COMPTE SUR LA TABLE BOOKING_ACCOUNT
    -- ------------------------------------------------------------------------
    LET $created = CREATE ONLY booking_account CONTENT {
        name: $clean_name,
        email: $clean_email,
        username: $clean_uname,
        password_hash: $password_hash,
        role: $clean_role,
        timezone: 'UTC',
        language: 'fr',
        enabled: true,
        created_at: time::now()
    };

    RETURN $created;
} COMMENT "Inscrit et crÃ©e un nouveau compte utilisateur dans la plateforme";
