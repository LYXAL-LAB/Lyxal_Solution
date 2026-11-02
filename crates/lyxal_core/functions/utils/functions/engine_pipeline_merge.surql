-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_pipeline_merge.surql
-- Fonction : fn::utils_engine_pipeline_merge
--
-- Concatène deux pipelines (déjà normalisés) en respectant la borne
-- $max_steps.
--
-- Paramètres
--   $left      : array<object>
--   $right     : array<object>
--   $max_steps : int
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : pipeline fusionné de plus de $max_steps étapes, ou $max_steps < 1
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_pipeline_merge(
    $left: array<object>,
    $right: array<object>,
    $max_steps: int
) -> array<object> {
    LET $merged = array::concat($left, $right);
    IF $max_steps < 1 OR array::len($merged) > $max_steps { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN $merged;
}
COMMENT "Concatène deux pipelines (déjà normalisés) en respectant la borne $max_steps."
PERMISSIONS FULL;
