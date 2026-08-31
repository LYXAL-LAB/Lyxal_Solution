-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_card
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_card(
    $value: string
) -> string {
    LET $digits = string::replace($value,<regex>"[^0-9]","");
    LET $length = string::len($digits);

    RETURN IF $length <= 4 {
        string::repeat("*",$length)
    } ELSE {
        string::concat(
            string::repeat("*",$length-4),
            string::slice($digits,$length-4,$length)
        )
    };
}
COMMENT "Masque un numéro de carte en conservant les quatre derniers chiffres."
PERMISSIONS FULL;
