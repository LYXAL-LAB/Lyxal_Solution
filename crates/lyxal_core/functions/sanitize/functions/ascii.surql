-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/ascii.surql
-- Fonction : fn::sanitize_ascii
--
-- Remplace chaque caractère non ASCII par une chaîne de remplacement.
--
-- Paramètres
--   $value       : any — valeur à nettoyer (chaîne, ou NONE)
--   $replacement : string — texte de remplacement (ex. "" ou "?")
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne ASCII
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $key = fn::sanitize_ascii($params.key, "");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_ascii(
    $value: any,
    $replacement: string
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"[^\\x00-\\x7F]", $replacement);
}
COMMENT "Remplace chaque caractère non ASCII par une chaîne de remplacement. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
