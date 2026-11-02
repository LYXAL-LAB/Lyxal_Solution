-- ============================================================================
-- LYXAL OS — CORE VALIDATIONS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/pipeline_execute.surql
-- Fonction : fn::validation_pipeline_execute
--
-- Valide une valeur avec un pipeline d'étapes { rule, options } du catalogue
-- (fn::validation_step_catalog), exécuté par le moteur unique (règles each,
-- object, when et one_of disponibles). Renvoie le rapport { valid, value,
-- errors, warnings, by_field } ; une donnée invalide ne lève jamais.
--
-- Paramètres
--   $value     : any
--   $pipeline  : array
--   $max_steps : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions validations)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT / CORE_UNSUPPORTED_OPTION : pipeline invalide (fn::utils_engine_pipeline)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_pipeline_execute(
    $value: any,
    $pipeline: array,
    $max_steps: int
) -> object {
    LET $steps = fn::utils_engine_pipeline($pipeline, fn::validation_step_catalog(), $max_steps);
    RETURN fn::utils_engine_report(
        fn::utils_engine_run(fn::utils_engine_state($value, "", NONE), $steps, |$current, $step| fn::validation_step_apply($current, $step))
    );
}
COMMENT "Valide une valeur avec un pipeline d'étapes { rule, options } du catalogue (fn::validation_step_catalog), exécuté par le moteur unique (règles each, object, when et one_of disponibles). Renvoie le rapport { valid, value, errors, warnings, by_field } ; une donnée invalide ne lève jamais."
PERMISSIONS FULL;
