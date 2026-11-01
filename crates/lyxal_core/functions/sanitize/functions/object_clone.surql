-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/object_clone.surql
-- Fonction : fn::sanitize_object_clone
--
-- Renvoie une copie superficielle d'un objet.
--
-- Paramètres
--   $value : any — valeur à nettoyer (objet, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la copie
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_object_clone($params.object_clone);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_clone(
    $value: any
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN object::from_entries(object::entries($value));
}
COMMENT "Renvoie une copie superficielle d'un objet. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
