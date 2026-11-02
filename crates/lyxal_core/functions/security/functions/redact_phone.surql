-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_phone.surql
-- Fonction : fn::security_redact_phone
--
-- Masque un numéro de téléphone en conservant ses derniers chiffres.
--
-- Paramètres
--   $value       : string
--   $visible_end : int
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $visible_end < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_redact_phone(
    $value: string,
    $visible_end: int
) -> string {
    IF $visible_end < 0 {
        THROW "CORE_INVALID_ARGUMENT";
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
