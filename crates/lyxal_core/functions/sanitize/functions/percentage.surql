-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/percentage.surql
-- Fonction : fn::sanitize_percentage
--
-- Extrait un pourcentage d'une saisie texte : symbole « % » retiré, puis
-- nettoyage décimal (voir sanitize_decimal).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre décimal en texte
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_percentage($params.percentage);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_percentage(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN fn::sanitize_decimal(string::replace($value, "%", ""));
}
COMMENT "Extrait un pourcentage d'une saisie texte : symbole « % » retiré, puis nettoyage décimal (voir sanitize_decimal). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
