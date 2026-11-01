-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_objects.surql
-- Fonction : fn::sanitize_array_objects
--
-- Ne garde que les objets d'un tableau.
--
-- Paramètres
--   $value : any — valeur à nettoyer (tableau, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau des objets
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_array_objects($params.array_objects);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_objects(
    $value: any
) -> option<array> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN array::filter($value, |$item| type::is_object($item));
}
COMMENT "Ne garde que les objets d'un tableau. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
