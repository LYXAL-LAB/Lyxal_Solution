-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/positive.surql
-- Fonction : fn::sanitize_positive
--
-- Extrait un nombre décimal d'une saisie texte (voir sanitize_decimal) et
-- retire son signe « - ».
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre sans signe
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_positive($params.positive);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_positive(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(fn::sanitize_decimal($value), <regex>"^-", "");
}
COMMENT "Extrait un nombre décimal d'une saisie texte (voir sanitize_decimal) et retire son signe « - ». NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
