-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/safe_extension.surql
-- Fonction : fn::sanitize_safe_extension
--
-- Normalise une extension de fichier : minuscules, points initiaux retirés,
-- caractères hors [a-z0-9] supprimés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'extension sans point
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_safe_extension($params.safe_extension);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_extension(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::replace(string::lowercase(string::trim($value)), <regex>"^\\.+", ""), <regex>"[^a-z0-9]", "");
}
COMMENT "Normalise une extension de fichier : minuscules, points initiaux retirés, caractères hors [a-z0-9] supprimés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
