-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/round.surql
-- Fonction : fn::sanitize_round
--
-- Arrondit un nombre à N décimales (arrondi au plus proche).
--
-- Paramètres
--   $value     : any — valeur à nettoyer (nombre, ou NONE)
--   $precision : int — nombre de décimales (>= 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre arrondi
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $precision < 0
--
-- Exemple
--   LET $rate = fn::sanitize_round($params.rate, 2);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_round(
    $value: any,
    $precision: int
) -> option<number> {
    IF $precision < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_number($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $factor = math::pow(10, $precision);
    RETURN math::round($value * $factor) / $factor;
}
COMMENT "Arrondit un nombre à N décimales (arrondi au plus proche). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
