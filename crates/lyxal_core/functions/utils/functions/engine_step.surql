-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_step.surql
-- Fonction : fn::utils_engine_step
--
-- Construit une étape de pipeline { rule, value, options } : nom de règle en
-- minuscules, options {} par défaut.
--
-- Paramètres
--   $rule    : string
--   $value   : any
--   $options : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nom de règle vide
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_step(
    $rule: string,
    $value: any,
    $options: option<object>
) -> object {
    LET $clean_rule = string::lowercase(string::trim($rule));
    IF $clean_rule = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN { rule: $clean_rule, value: $value, options: $options ?? {} };
}
COMMENT "Construit une étape de pipeline { rule, value, options } : nom de règle en minuscules, options {} par défaut."
PERMISSIONS FULL;
