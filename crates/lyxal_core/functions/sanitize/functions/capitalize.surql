-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/capitalize.surql
-- Fonction : fn::sanitize_capitalize
--
-- Met la première lettre d'une chaîne en majuscule et le reste en
-- minuscules.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne capitalisée
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_capitalize($params.capitalize);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_capitalize(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $lower = string::lowercase($value);
    RETURN string::uppercase(string::slice($lower, 0, 1)) + string::slice($lower, 1);
}
COMMENT "Met la première lettre d'une chaîne en majuscule et le reste en minuscules. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
