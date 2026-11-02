-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/secret_validate.surql
-- Fonction : fn::security_secret_validate
--
-- Évalue des contraintes structurelles minimales sur un secret.
--
-- Paramètres
--   $secret     : string
--   $min_length : int
--   $max_length : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1 OR $max_length < $min_length
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_secret_validate(
    $secret: string,
    $min_length: int,
    $max_length: int
) -> object {
    IF $min_length < 1 OR $max_length < $min_length {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $length = string::len($secret);

    RETURN {
        valid: $length >= $min_length
            AND $length <= $max_length
            AND string::matches($secret,"[A-Za-z]")
            AND string::matches($secret,"[0-9]"),
        length: $length,
        has_letters: string::matches($secret,"[A-Za-z]"),
        has_digits: string::matches($secret,"[0-9]"),
        has_symbols: string::matches($secret,"[^A-Za-z0-9]")
    };
}
COMMENT "Évalue des contraintes structurelles minimales sur un secret."
PERMISSIONS FULL;
