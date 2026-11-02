-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/safe_redirect.surql
-- Fonction : fn::sanitize_safe_redirect
--
-- Garantit une cible de redirection interne : seul un chemin relatif à la
-- racine (« /… », mais pas « // » ni « /\ ») est conservé ; toute autre
-- valeur (URL absolue, javascript:, data:…) est remplacée par la valeur de
-- repli.
--
-- Paramètres
--   $value    : any — valeur à nettoyer (chaîne, ou NONE)
--   $fallback : string — chemin de repli (doit commencer par « / »)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le chemin interne, ou $fallback
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $fallback qui n'est pas un chemin interne
--
-- Exemple
--   LET $next = fn::sanitize_safe_redirect($params.next, "/");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_safe_redirect(
    $value: any,
    $fallback: string
) -> option<string> {
    IF !string::starts_with($fallback, "/") OR string::starts_with($fallback, "//") { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $target = string::trim($value);
    RETURN IF string::starts_with($target, "/") AND !string::starts_with($target, "//") AND !string::starts_with($target, "/\\") { $target } ELSE { $fallback };
}
COMMENT "Garantit une cible de redirection interne : seul un chemin relatif à la racine (« /… », mais pas « // » ni « /\\ ») est conservé. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
