-- ============================================================================
-- GENERATION DETERMINISTE D'UN PSEUDO UNIQUE A PARTIR D'UNE ADRESSE EMAIL
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_generate_username(
    $params: object
) {
    LET $email = $params.email;
    LET $language = $params.language OR "fr";

    IF $email == NONE OR string::len(string::trim($email)) == 0 {
        RETURN fn::result_error("BOOKING_USERNAME_EMAIL_REQUIRED", $language, { field: "email" });
    };

    LET $parts = string::split(string::trim($email), "@");
    LET $base = string::lowercase(string::slug($parts[0]));

    IF string::len($base) == 0 {
        LET $base = "user";
    };

    LET $candidate = $base;
    LET $counter = 1;

    -- Boucle de détection d'unicité
    FOR $i IN [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] {
        LET $existing = SELECT id FROM booking_account WHERE username = $candidate LIMIT 1;
        IF array::len($existing) == 0 {
            RETURN fn::result_ok({ username: $candidate });
        };

        LET $counter = $counter + 1;
        LET $candidate = string::concat($base, <string>$counter);
    };

    RETURN fn::result_error("BOOKING_USERNAME_GENERATION_FAILED", $language, { base: $base });
};
