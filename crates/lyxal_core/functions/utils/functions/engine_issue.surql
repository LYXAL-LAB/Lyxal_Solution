-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_issue.surql
-- Fonction : fn::utils_engine_issue
--
-- Ajoute une erreur { path, rule, code, details } à l'état et arrête le
-- pipeline en cours (stop = true).
--
-- Paramètres
--   $state   : object
--   $rule    : string
--   $code    : string
--   $details : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : code vide
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_issue(
    $state: object,
    $rule: string,
    $code: string,
    $details: option<object>
) -> object {
    IF string::trim($code) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN object::extend($state, {
        issues: array::append($state.issues, { path: $state.path, rule: $rule, code: $code, details: $details ?? {} }),
        stop: true
    });
}
COMMENT "Ajoute une erreur { path, rule, code, details } à l'état et arrête le pipeline en cours (stop = true)."
PERMISSIONS FULL;
