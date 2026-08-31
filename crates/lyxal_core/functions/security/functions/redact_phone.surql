-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_phone
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_phone(
    $value: string,
    $visible_end: int
) -> string {
    IF $visible_end < 0 {
        THROW "SECURITY_INVALID_REDACT_PHONE_VISIBILITY";
    };

    LET $digits = string::replace($value,<regex>"[^0-9]","");
    LET $length = string::len($digits);

    RETURN IF $visible_end >= $length {
        $digits
    } ELSE {
        string::concat(
            string::repeat("*",$length-$visible_end),
            string::slice($digits,$length-$visible_end,$length)
        )
    };
}
COMMENT "Masque un numéro de téléphone en conservant ses derniers chiffres."
PERMISSIONS FULL;
