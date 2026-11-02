-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/pipeline_execute.surql
-- Fonction : fn::sanitize_pipeline_execute
--
-- Nettoie une valeur avec un pipeline d'étapes { rule, options } du
-- catalogue sanitize (fn::sanitize_step_catalog), exécuté par le moteur
-- unique ; les règles each, object, when et one_of du moteur sont
-- disponibles. Renvoie la valeur nettoyée.
--
-- Paramètres
--   $value     : any
--   $pipeline  : array
--   $max_steps : int
--
-- Valeur renvoyée : any (contrat : crates/lyxal_core/Readme.md, fonctions sanitize)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT / CORE_UNSUPPORTED_OPTION : pipeline invalide (fn::utils_engine_pipeline)
--   CORE_SANITIZE_INVALID_TYPE : donnée non nettoyable (type inattendu, ou erreur levée par une règle du moteur : la donnée aurait dû être validée avant)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_execute(
    $value: any,
    $pipeline: array,
    $max_steps: int
) -> any {
    LET $steps = fn::utils_engine_pipeline($pipeline, fn::sanitize_step_catalog(), $max_steps);
    LET $state = fn::utils_engine_run(fn::utils_engine_state($value, "", NONE), $steps, |$current, $step| fn::sanitize_step_apply($current, $step));
    IF array::len($state.issues) > 0 { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN $state.value;
}
COMMENT "Nettoie une valeur avec un pipeline d'étapes { rule, options } du catalogue sanitize (fn::sanitize_step_catalog), exécuté par le moteur unique ; les règles each, object, when et one_of du moteur sont disponibles. Renvoie la valeur nettoyée."
PERMISSIONS FULL;
