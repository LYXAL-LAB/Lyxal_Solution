-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_optimize.surql
-- Fonction : fn::utils_engine_optimize
--
-- Optimise un pipeline sans changer son résultat : supprime une étape
-- identique à la précédente lorsque sa règle est déclarée idempotente par le
-- catalogue (idempotent: true). Aucun réordonnancement (décision CTO : il
-- modifierait le résultat). Renvoie { pipeline, removed, cost_before,
-- cost_after }.
--
-- Paramètres
--   $pipeline : array<object>
--   $catalog  : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_optimize(
    $pipeline: array<object>,
    $catalog: array<object>
) -> object {
    LET $idempotent = array::map(array::filter($catalog, |$entry| $entry.idempotent = true), |$entry| $entry.rule);
    LET $optimized = array::fold($pipeline, [], |$kept, $step|
        IF array::len($kept) > 0 AND $step.rule IN $idempotent AND $kept[array::len($kept) - 1] == $step { $kept } ELSE { array::append($kept, $step) }
    );
    RETURN {
        pipeline: $optimized,
        removed: array::len($pipeline) - array::len($optimized),
        cost_before: fn::utils_engine_pipeline_info($pipeline, $catalog).cost,
        cost_after: fn::utils_engine_pipeline_info($optimized, $catalog).cost
    };
}
COMMENT "Optimise un pipeline sans changer son résultat : supprime une étape identique à la précédente lorsque sa règle est déclarée idempotente par le catalogue (idempotent: true). Aucun réordonnancement (décision CTO : il modifierait le résultat). Renvoie { pipeline, removed, cost_before, cost_after }."
PERMISSIONS FULL;
