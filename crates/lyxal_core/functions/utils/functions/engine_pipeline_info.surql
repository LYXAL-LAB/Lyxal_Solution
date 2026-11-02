-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_pipeline_info.surql
-- Fonction : fn::utils_engine_pipeline_info
--
-- Décrit un pipeline : nombre d'étapes, règles distinctes et coût total des
-- étapes de premier niveau (coût du catalogue, 1 par défaut).
--
-- Paramètres
--   $pipeline : array<object>
--   $catalog  : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_pipeline_info(
    $pipeline: array<object>,
    $catalog: array<object>
) -> object {
    RETURN {
        step_count: array::len($pipeline),
        rules: array::distinct(array::map($pipeline, |$step| $step.rule)),
        cost: math::sum(array::map($pipeline, |$step| array::find($catalog, |$entry| $entry.rule = $step.rule).cost ?? 1))
    };
}
COMMENT "Décrit un pipeline : nombre d'étapes, règles distinctes et coût total des étapes de premier niveau (coût du catalogue, 1 par défaut)."
PERMISSIONS FULL;
