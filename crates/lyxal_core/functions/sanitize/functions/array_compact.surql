-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array_compact.surql
-- Fonction : fn::sanitize_array_compact
--
-- Retire d'un tableau les éléments NONE et, si demandé, NULL et les chaînes
-- vides (après nettoyage).
--
-- Paramètres
--   $value                : any — valeur à nettoyer (tableau, ou NONE)
--   $remove_null          : bool — retirer les NULL
--   $remove_blank_strings : bool — retirer les chaînes vides ou blanches
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le tableau compacté
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $tags = fn::sanitize_array_compact($params.tags, true, true);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_compact(
    $value: any,
    $remove_null: bool,
    $remove_blank_strings: bool
) -> option<array> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_array($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN array::filter($value, |$item| $item IS NOT NONE
        AND (!$remove_null OR !type::is_null($item))
        AND (!$remove_blank_strings OR !type::is_string($item) OR string::trim($item) != ""));
}
COMMENT "Retire d'un tableau les éléments NONE et, si demandé, NULL et les chaînes vides (après nettoyage). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
