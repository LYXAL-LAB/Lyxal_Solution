-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/clamp.surql
-- Fonction : fn::sanitize_clamp
--
-- Ramène un nombre dans un intervalle [min, max].
--
-- Paramètres
--   $value : any — valeur à nettoyer (nombre, ou NONE)
--   $min   : number — borne minimale
--   $max   : number — borne maximale (>= $min)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre borné
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min > $max
--
-- Exemple
--   LET $qty = fn::sanitize_clamp($params.quantity, 1, 100);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_clamp(
    $value: any,
    $min: number,
    $max: number
) -> option<number> {
    IF $min > $max { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_number($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN IF $value < $min { $min } ELSE IF $value > $max { $max } ELSE { $value };
}
COMMENT "Ramène un nombre dans un intervalle [min, max]. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
