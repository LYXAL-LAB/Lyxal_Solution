-- ============================================================================
-- PERSISTANCE ET LIAISON SECURISEE DE COMPTE OIDC (AVEC SYNCHRO TITRE)
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_find_or_create_oidc_account(
    $params: object
) {
    LET $issuer = $params.issuer;
    LET $sub = $params.sub;
    LET $email = $params.email;
    LET $email_verified = $params.email_verified OR false;
    LET $name = $params.name;
    LET $picture = $params.picture;
    LET $title = $params.title;
    LET $auto_register = $params.auto_register OR false;
    LET $language = $params.language OR "fr";

    -- Validation explicite séparée des champs obligatoires
    IF $issuer == NONE OR string::len(string::trim($issuer)) == 0 {
        RETURN fn::result_error("BOOKING_AUTH_OIDC_INVALID_ISSUER", $language, { field: "issuer" });
    };

    IF $sub == NONE OR string::len(string::trim($sub)) == 0 {
        RETURN fn::result_error("BOOKING_AUTH_OIDC_INVALID_SUBJECT", $language, { field: "sub" });
    };

    IF $email == NONE OR string::len(string::trim($email)) == 0 {
        RETURN fn::result_error("BOOKING_USERNAME_EMAIL_REQUIRED", $language, { field: "email" });
    };

    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        RETURN fn::result_error("BOOKING_AUTH_OIDC_NAME_REQUIRED", $language, { field: "name" });
    };

    LET $clean_email = string::lowercase(string::trim($email));

    -- 1. Recherche par OIDC issuer + subject (Index unique composite)
    LET $by_sub = SELECT * FROM booking_account WHERE oidc_issuer = $issuer AND oidc_sub = $sub LIMIT 1;
    IF array::len($by_sub) > 0 {
        LET $acc = $by_sub[0];
        IF $acc.enabled == false {
            RETURN fn::result_error("BOOKING_AUTH_USER_DISABLED", $language, { user_id: $acc.id });
        };

        -- Synchronisation du nom et du titre OIDC (AUDIT-003)
        IF $title != NONE AND string::len(string::trim($title)) > 0 {
            UPDATE $acc.id SET title = string::trim($title), updated_at = time::now();
        };

        RETURN fn::result_ok({
            id: $acc.id,
            name: $acc.name,
            email: $acc.email,
            username: $acc.username,
            role: $acc.role,
            timezone: $acc.timezone,
            language: $acc.language,
            enabled: $acc.enabled
        });
    };

    -- 2. Recherche par email pour lier un compte existant (REFUS SI NON VERIFIE OU DESACTIVE)
    LET $by_email = SELECT * FROM booking_account WHERE email = $clean_email LIMIT 1;
    IF array::len($by_email) > 0 {
        IF $email_verified == false {
            RETURN fn::result_error("BOOKING_AUTH_OIDC_EMAIL_NOT_VERIFIED", $language, { email: $clean_email });
        };

        LET $existing = $by_email[0];
        IF $existing.enabled == false {
            RETURN fn::result_error("BOOKING_AUTH_USER_DISABLED", $language, { user_id: $existing.id });
        };

        IF $title != NONE AND string::len(string::trim($title)) > 0 {
            UPDATE $existing.id SET oidc_issuer = $issuer, oidc_sub = $sub, title = string::trim($title), updated_at = time::now();
        } ELSE {
            UPDATE $existing.id SET oidc_issuer = $issuer, oidc_sub = $sub, updated_at = time::now();
        };

        RETURN fn::result_ok({
            id: $existing.id,
            name: $existing.name,
            email: $existing.email,
            username: $existing.username,
            role: $existing.role,
            timezone: $existing.timezone,
            language: $existing.language,
            enabled: $existing.enabled
        });
    };

    -- 3. Inscription automatique (REFUS SI DESACTIVEE OU EMAIL NON VERIFIE)
    IF $email_verified == false {
        RETURN fn::result_error("BOOKING_AUTH_OIDC_EMAIL_NOT_VERIFIED", $language, { email: $clean_email });
    };

    IF $auto_register == false {
        RETURN fn::result_error("BOOKING_AUTH_OIDC_ACCOUNT_NOT_LINKED", $language, { email: $clean_email });
    };

    -- Génération déterministe d'un pseudo unique (Propagation d'erreur stricte)
    LET $uname_res = fn::booking_generate_username({ email: $clean_email, language: $language });
    IF $uname_res.ok == false {
        RETURN $uname_res;
    };
    LET $username = $uname_res.data.username;

    LET $now = time::now();
    LET $new_acc = CREATE ONLY booking_account CONTENT {
        name: string::trim($name),
        email: $clean_email,
        username: $username,
        title: IF $title != NONE { string::trim($title) } ELSE { NONE },
        oidc_issuer: $issuer,
        oidc_sub: $sub,
        role: "user",
        timezone: "UTC",
        language: $language,
        enabled: true,
        created_at: $now,
        updated_at: $now
    };

    RETURN fn::result_ok({
        id: $new_acc.id,
        name: $new_acc.name,
        email: $new_acc.email,
        username: $new_acc.username,
        role: $new_acc.role,
        timezone: $new_acc.timezone,
        language: $new_acc.language,
        enabled: $new_acc.enabled
    });
};
