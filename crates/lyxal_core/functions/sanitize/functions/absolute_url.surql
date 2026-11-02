-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/absolute_url.surql
-- Fonction : fn::sanitize_absolute_url
--
-- Rend une URL absolue : une valeur sans schéma (« example.com/a ») reçoit
-- le schéma par défaut ; une chaîne vide reste vide.
--
-- Paramètres
--   $value          : any — valeur à nettoyer (chaîne, ou NONE)
--   $default_scheme : string — schéma ajouté si absent (ex. "https")
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'URL avec schéma
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $default_scheme qui n'est pas un schéma valide
--
-- Exemple
--   LET $site = fn::sanitize_absolute_url($params.website, "https");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_absolute_url(
    $value: any,
    $default_scheme: string
) -> option<string> {
    LET $scheme = string::lowercase(string::trim($default_scheme));
    IF !string::matches($scheme, "^[a-z][a-z0-9+.-]*$") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $clean = string::trim($value);
    RETURN IF $clean = "" OR string::matches($clean, "^[a-zA-Z][a-zA-Z0-9+.-]*://") { $clean } ELSE { $scheme + "://" + $clean };
}
COMMENT "Rend une URL absolue : une valeur sans schéma (« example.com/a ») reçoit le schéma par défaut. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
