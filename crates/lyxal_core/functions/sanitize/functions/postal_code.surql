-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/postal_code.surql
-- Fonction : fn::sanitize_postal_code
--
-- Normalise un code postal : majuscules, caractères hors [A-Z0-9-]
-- supprimés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le code postal normalisé
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_postal_code($params.postal_code);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_postal_code(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::uppercase($value), <regex>"[^A-Z0-9-]", "");
}
COMMENT "Normalise un code postal : majuscules, caractères hors [A-Z0-9-] supprimés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
