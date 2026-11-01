-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/date.surql
-- Fonction : fn::sanitize_date
--
-- Ramène un datetime à minuit UTC du même jour.
--
-- Paramètres
--   $value : any — valeur à nettoyer (datetime, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le datetime à minuit
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_date($params.date);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_date(
    $value: any
) -> option<datetime> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_datetime($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN time::floor($value, 1d);
}
COMMENT "Ramène un datetime à minuit UTC du même jour. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
