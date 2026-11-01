-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/keep_keys.surql
-- Fonction : fn::sanitize_keep_keys
--
-- Ne garde que les clés listées d'un objet (même effet que
-- sanitize_remove_unknown_keys).
--
-- Paramètres
--   $value : any — valeur à nettoyer (objet, ou NONE)
--   $keys  : array<string> — clés conservées
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet filtré
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $input = fn::sanitize_keep_keys($params, ["name"]);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_keep_keys(
    $value: any,
    $keys: array<string>
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN fn::sanitize_remove_unknown_keys($value, $keys);
}
COMMENT "Ne garde que les clés listées d'un objet (même effet que sanitize_remove_unknown_keys). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
