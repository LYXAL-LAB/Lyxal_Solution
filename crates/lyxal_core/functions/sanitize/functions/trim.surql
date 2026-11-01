-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/trim.surql
-- Fonction : fn::sanitize_trim
--
-- Retire les espaces périphériques d'une chaîne.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne sans espaces périphériques
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $name = fn::sanitize_trim($params.name);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_trim(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::trim($value);
}
COMMENT "Retire les espaces périphériques d'une chaîne. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
