-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_empty.surql
-- Fonction : fn::sanitize_remove_empty
--
-- Retire d'un objet les clés NONE et, selon les options, les valeurs NULL,
-- chaînes vides, tableaux vides et objets vides (premier niveau).
--
-- Paramètres
--   $value                : any — valeur à nettoyer (objet, ou NONE)
--   $remove_null          : bool — retirer les NULL
--   $remove_blank_strings : bool — retirer les chaînes vides ou blanches
--   $remove_empty_arrays  : bool — retirer les tableaux vides
--   $remove_empty_objects : bool — retirer les objets vides
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet nettoyé
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $patch = fn::sanitize_remove_empty($params.patch, true, true, false, false);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_empty(
    $value: any,
    $remove_null: bool,
    $remove_blank_strings: bool,
    $remove_empty_arrays: bool,
    $remove_empty_objects: bool
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN object::from_entries(array::filter(object::entries($value), |$entry| $entry[1] IS NOT NONE
        AND (!$remove_null OR !type::is_null($entry[1]))
        AND (!$remove_blank_strings OR !type::is_string($entry[1]) OR string::trim($entry[1]) != "")
        AND (!$remove_empty_arrays OR !type::is_array($entry[1]) OR array::len($entry[1]) > 0)
        AND (!$remove_empty_objects OR !type::is_object($entry[1]) OR !object::is_empty($entry[1]))));
}
COMMENT "Retire d'un objet les clés NONE et, selon les options, les valeurs NULL, chaînes vides, tableaux vides et objets vides (premier niveau). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
