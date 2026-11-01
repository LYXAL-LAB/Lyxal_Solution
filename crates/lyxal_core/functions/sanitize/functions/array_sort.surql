-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_sort.surql
-- Fonction : fn::sanitize_array_sort
--
-- Trie un tableau par ordre croissant ou décroissant.
--
-- Paramètres
--   $value     : any — valeur à nettoyer (tableau, ou NONE)
--   $direction : string — "asc" ou "desc", insensible à la casse
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau trié
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : sens inconnu
--
-- Exemple
--   LET $sorted = fn::sanitize_array_sort($params.values, "asc");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_sort(
    $value: any,
    $direction: string
) -> option<array> {
    LET $order = string::lowercase(string::trim($direction));
    IF $order NOT IN ["asc", "desc"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN IF $order = "asc" { array::sort::asc($value) } ELSE { array::sort::desc($value) };
}
COMMENT "Trie un tableau par ordre croissant ou décroissant. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
