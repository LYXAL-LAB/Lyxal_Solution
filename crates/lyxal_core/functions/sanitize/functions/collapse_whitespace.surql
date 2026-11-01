-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/collapse_whitespace.surql
-- Fonction : fn::sanitize_collapse_whitespace
--
-- Remplace toute suite d'espaces, tabulations ou retours à la ligne par une
-- espace simple, puis retire les espaces périphériques.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne aux espaces normalisés
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_collapse_whitespace($params.collapse_whitespace);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_collapse_whitespace(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::trim(string::replace($value, <regex>"\\s+", " "));
}
COMMENT "Remplace toute suite d'espaces, tabulations ou retours à la ligne par une espace simple, puis retire les espaces périphériques. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
