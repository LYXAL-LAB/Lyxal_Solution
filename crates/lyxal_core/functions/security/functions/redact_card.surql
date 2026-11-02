-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_card.surql
-- Fonction : fn::security_redact_card
--
-- Masque un numéro de carte en conservant les quatre derniers chiffres.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
