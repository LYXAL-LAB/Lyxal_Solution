-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/country_code.surql
-- Fonction : fn::sanitize_country_code
--
-- Normalise un code pays : lettres seules, en majuscules.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le code en majuscules
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_country_code($params.country_code);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_country_code(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::uppercase(string::replace($value, <regex>"[^A-Za-z]", ""));
}
COMMENT "Normalise un code pays : lettres seules, en majuscules. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
