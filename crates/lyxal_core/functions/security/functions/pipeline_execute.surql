-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/pipeline_execute.surql
-- Fonction : fn::security_pipeline_execute
--
-- Applique un pipeline security (masquage, empreintes, détections, contrôles
-- de permission) à une valeur avec le moteur unique ; renvoie { value,
-- findings, score, decisions, allowed, errors } (fn::security_step_result).
--
-- Paramètres
--   $value     : any
--   $pipeline  : array
--   $max_steps : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT / CORE_UNSUPPORTED_OPTION : pipeline invalide (fn::utils_engine_pipeline) ou valeur d'un type inattendu
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_pipeline_execute(
    $value: any,
    $pipeline: array,
    $max_steps: int
) -> object {
    LET $steps = fn::utils_engine_pipeline($pipeline, fn::security_step_catalog(), $max_steps);
    RETURN fn::security_step_result(
        fn::utils_engine_run(fn::utils_engine_state($value, "", NONE), $steps, |$current, $step| fn::security_step_apply($current, $step))
    );
}
COMMENT "Applique un pipeline security (masquage, empreintes, détections, contrôles de permission) à une valeur avec le moteur unique ; renvoie { value, findings, score, decisions, allowed, errors } (fn::security_step_result)."
PERMISSIONS FULL;
