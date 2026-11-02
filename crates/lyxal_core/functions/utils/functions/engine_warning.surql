-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_warning.surql
-- Fonction : fn::utils_engine_warning
--
-- Ajoute un avertissement { path, rule, code, details } à l'état sans
-- arrêter le pipeline.
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
DEFINE FUNCTION OVERWRITE fn::utils_engine_warning(
    $state: object,
    $rule: string,
    $code: string,
    $details: option<object>
) -> object {
    IF string::trim($code) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN object::extend($state, {
        warnings: array::append($state.warnings, { path: $state.path, rule: $rule, code: $code, details: $details ?? {} })
    });
}
COMMENT "Ajoute un avertissement { path, rule, code, details } à l'état sans arrêter le pipeline."
PERMISSIONS FULL;
