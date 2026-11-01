-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_unknown_keys.surql
-- Fonction : fn::sanitize_remove_unknown_keys
--
-- Ne garde que les clés autorisées d'un objet.
--
-- Paramètres
--   $value        : any — valeur à nettoyer (objet, ou NONE)
--   $allowed_keys : array<string> — clés conservées
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet filtré
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $input = fn::sanitize_remove_unknown_keys($params, ["name", "email"]);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_unknown_keys(
    $value: any,
    $allowed_keys: array<string>
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN object::from_entries(array::filter(object::entries($value), |$entry| $entry[0] IN $allowed_keys));
}
COMMENT "Ne garde que les clés autorisées d'un objet. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
