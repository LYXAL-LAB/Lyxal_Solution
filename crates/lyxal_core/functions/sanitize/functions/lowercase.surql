-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/lowercase.surql
-- Fonction : fn::sanitize_lowercase
--
-- Met une chaîne en minuscules (Unicode).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne en minuscules
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_lowercase($params.lowercase);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_lowercase(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::lowercase($value);
}
COMMENT "Met une chaîne en minuscules (Unicode). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
