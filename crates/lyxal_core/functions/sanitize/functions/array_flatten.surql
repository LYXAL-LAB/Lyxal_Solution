-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_flatten.surql
-- Fonction : fn::sanitize_array_flatten
--
-- Aplatit d'un niveau un tableau de tableaux.
--
-- Paramètres
--   $value : any — valeur à nettoyer (tableau, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau aplati
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_array_flatten($params.array_flatten);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_flatten(
    $value: any
) -> option<array> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN array::flatten($value);
}
COMMENT "Aplatit d'un niveau un tableau de tableaux. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
