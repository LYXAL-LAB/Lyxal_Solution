-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/default_values.surql
-- Fonction : fn::sanitize_default_values
--
-- Complète un objet avec des valeurs par défaut : chaque clé absente (ou
-- NONE) de l'objet prend la valeur par défaut ; les autres clés de l'objet
-- sont conservées.
--
-- Paramètres
--   $value    : any — valeur à nettoyer (objet, ou NONE)
--   $defaults : object — valeurs par défaut
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet complété
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $prefs = fn::sanitize_default_values($params.prefs, { language: "fr" });
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_default_values(
    $value: any,
    $defaults: object
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN object::extend($defaults, object::from_entries(array::filter(object::entries($value), |$entry| $entry[1] IS NOT NONE)));
}
COMMENT "Complète un objet avec des valeurs par défaut : chaque clé absente (ou NONE) de l'objet prend la valeur par défaut. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
