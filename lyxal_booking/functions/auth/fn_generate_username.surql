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

    LET $trimmed = string::trim($email);
    LET $raw_local = IF string::contains($trimmed, "@") { string::split($trimmed, "@")[0] } ELSE { $trimmed };
    LET $lower = string::lowercase($raw_local);

    -- Remplacer . par - puis nettoyer les caractères spéciaux (!, +, etc.)
    LET $s1 = string::replace($lower, ".", "-");
    LET $s2 = string::replace($s1, "!", "");
    LET $s3 = string::replace($s2, "+", "");
    LET $s4 = string::replace($s3, "_", "-");

    LET $base = IF string::len($s4) == 0 { "user" } ELSE { $s4 };

    LET $existing_base = SELECT VALUE id FROM booking_account WHERE username = $base LIMIT 1;
    IF array::len($existing_base) == 0 {
        RETURN fn::result_ok({ username: $base });
    };

    -- Boucle de détection d'unicité avec suffixe numérique
    FOR $i IN [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20] {
        LET $candidate = string::concat($base, "-", <string>$i);
        LET $existing = SELECT VALUE id FROM booking_account WHERE username = $candidate LIMIT 1;
        IF array::len($existing) == 0 {
            RETURN fn::result_ok({ username: $candidate });
        };
    };

    RETURN fn::result_error("BOOKING_USERNAME_GENERATION_FAILED", $language, { base: $base });
};
