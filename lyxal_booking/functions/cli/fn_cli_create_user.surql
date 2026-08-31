-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ fn::booking_cli_create_user                                              │
-- │ Création d'utilisateur atomique via CLI avec auto-promotion admin       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_cli_create_user($params: object) {
    LET $email = string::lowercase(string::trim($params.email));
    LET $name = string::trim($params.name);
    LET $password_hash = $params.password_hash;
    LET $req_admin = $params.admin OR false;

    -- Vérifier l'unicité de l'email
    LET $existing = (SELECT id FROM booking_account WHERE email = $email LIMIT 1);
    IF array::len($existing) > 0 {
        RETURN fn::result_error("BOOKING_USER_EMAIL_EXISTS", "fr", { email: $email });
    };

    -- Compter les comptes existants pour auto-promouvoir le 1er utilisateur
    LET $total = (SELECT count() FROM booking_account GROUP ALL);
    LET $total_count = IF array::len($total) > 0 { $total[0].count } ELSE { 0 };

    LET $role = IF $total_count == 0 { "admin" } ELSE IF $req_admin { "admin" } ELSE { "user" };

    LET $created = (CREATE ONLY booking_account SET
        email = $email,
        name = $name,
        password_hash = $password_hash,
        role = $role,
        enabled = true,
        auth_provider = "local",
        created_at = time::now(),
        updated_at = time::now()
    );

    RETURN fn::result_ok({
        account_id: $created.id,
        email: $created.email,
        name: $created.name,
        role: $created.role,
        first_account: ($total_count == 0)
    });
};
