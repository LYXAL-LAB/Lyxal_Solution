-- ============================================================================
-- RECHERCHE NEUTRE DE COMPTE POUR AUTHENTIFICATION
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_lookup_auth_account(
    $params: object
) {
    LET $email = $params.email;

    IF $email == NONE OR string::len(string::trim($email)) == 0 {
        RETURN fn::result_ok({
            account: NONE
        });
    };

    LET $clean_email = string::lowercase(string::trim($email));

    LET $user = (
        SELECT *
        FROM ONLY booking_account
        WHERE email = $clean_email
        LIMIT 1
    );

    IF $user == NONE {
        RETURN fn::result_ok({
            account: NONE
        });
    };

    RETURN fn::result_ok({
        account: {
            id: $user.id,
            name: $user.name,
            email: $user.email,
            username: $user.username,
            password_hash: $user.password_hash,
            role: $user.role,
            timezone: $user.timezone,
            language: $user.language,
            enabled: $user.enabled
        }
    });
};
