-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/object_merge.surql
-- Fonction : fn::sanitize_object_merge
--
-- Fusionne deux objets : les clés de $override remplacent celles de $value
-- (fusion superficielle).
--
-- Paramètres
--   $value    : any — valeur à nettoyer (objet, ou NONE)
--   $override : object — objet prioritaire
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet fusionné
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $settings = fn::sanitize_object_merge($current, $params.settings);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_merge(
    $value: any,
    $override: object
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN object::extend($value, $override);
}
COMMENT "Fusionne deux objets : les clés de $override remplacent celles de $value (fusion superficielle). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
