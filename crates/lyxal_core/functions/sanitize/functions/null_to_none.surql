-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/null_to_none.surql
-- Fonction : fn::sanitize_null_to_none
--
-- Remplace par NONE les valeurs NULL d'un objet (premier niveau).
--
-- Paramètres
--   $value : any — valeur à nettoyer (objet, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet sans NULL
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_null_to_none($params.null_to_none);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_null_to_none(
    $value: any
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN object::from_entries(array::map(object::entries($value), |$entry| [$entry[0], IF type::is_null($entry[1]) { NONE } ELSE { $entry[1] }]));
}
COMMENT "Remplace par NONE les valeurs NULL d'un objet (premier niveau). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
