-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_limit.surql
-- Fonction : fn::sanitize_array_limit
--
-- Tronque un tableau à ses N premiers éléments.
--
-- Paramètres
--   $value : any — valeur à nettoyer (tableau, ou NONE)
--   $limit : int — nombre maximal d'éléments (>= 0)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau tronqué
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $limit < 0
--
-- Exemple
--   LET $items = fn::sanitize_array_limit($params.items, 50);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_limit(
    $value: any,
    $limit: int
) -> option<array> {
    IF $limit < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN array::slice($value, 0, $limit);
}
COMMENT "Tronque un tableau à ses N premiers éléments. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
