-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/port.surql
-- Fonction : fn::sanitize_port
--
-- Extrait les chiffres d'une saisie de port.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : les chiffres de la saisie
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_port($params.port);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_port(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace($value, <regex>"[^0-9]", "");
}
COMMENT "Extrait les chiffres d'une saisie de port. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
