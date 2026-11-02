-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/remove_tracking.surql
-- Fonction : fn::sanitize_remove_tracking
--
-- Retire d'une URL les paramètres de suivi (utm_*, fbclid, gclid, mc_cid,
-- mc_eid) en gardant les autres paramètres et le fragment.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'URL sans paramètre de suivi
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_remove_tracking($params.remove_tracking);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_tracking(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $marked = string::replace(string::replace(string::trim($value), <regex>"\\?(utm_[^=&#]+|fbclid|gclid|mc_cid|mc_eid)=[^&#]*", "?"), <regex>"&(utm_[^=&#]+|fbclid|gclid|mc_cid|mc_eid)=[^&#]*", "&");
    LET $joined = string::replace(string::replace($marked, <regex>"&{2,}", "&"), <regex>"\\?&+", "?");
    RETURN string::replace(string::replace($joined, <regex>"[?&]+#", "#"), <regex>"[?&]+$", "");
}
COMMENT "Retire d'une URL les paramètres de suivi (utm_*, fbclid, gclid, mc_cid, mc_eid) en gardant les autres paramètres et le fragment. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
