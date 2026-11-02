-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/safe_path.surql
-- Fonction : fn::sanitize_safe_path
--
-- Nettoie un chemin relatif : barres obliques inverses converties, segments
-- vides, « . » et « .. » supprimés (aucune remontée possible), sans « / »
-- initial ni final.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le chemin relatif sûr
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_safe_path($params.safe_path);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_path(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $segments = string::split(string::replace(string::trim($value), "\\", "/"), "/");
    RETURN array::join(array::filter($segments, |$segment| $segment NOT IN ["", ".", ".."]), "/");
}
COMMENT "Nettoie un chemin relatif : barres obliques inverses converties, segments vides, « . » et « .. » supprimés (aucune remontée possible), sans « / » initial ni final. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
