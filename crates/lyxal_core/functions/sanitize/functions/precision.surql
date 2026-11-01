-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/precision.surql
-- Fonction : fn::sanitize_precision
--
-- Arrondit un nombre à N décimales et le renvoie en decimal.
--
-- Paramètres
--   $value     : any — valeur à nettoyer (nombre, ou NONE)
--   $precision : int — nombre de décimales (>= 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le decimal arrondi
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $precision < 0
--
-- Exemple
--   LET $amount = fn::sanitize_precision($params.amount, 2);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_precision(
    $value: any,
    $precision: int
) -> option<decimal> {
    IF $precision < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_number($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN <decimal> fn::sanitize_round($value, $precision);
}
COMMENT "Arrondit un nombre à N décimales et le renvoie en decimal. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
