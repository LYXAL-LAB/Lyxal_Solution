-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_debug_summary.surql
-- Fonction : fn::utils_engine_debug_summary
--
-- Résume des traces de débogage : nombre, échecs, durée totale, et par règle
-- { count, failed, total_duration }.
--
-- Paramètres
--   $traces : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_debug_summary(
    $traces: array<object>
) -> object {
    LET $total = |$items: array| array::fold($items, 0ns, |$sum, $trace| $sum + $trace.duration);
    RETURN {
        trace_count: array::len($traces),
        failed_count: array::len(fn::utils_engine_debug_failed($traces)),
        total_duration: $total($traces),
        by_rule: object::from_entries(array::map(array::distinct(array::map($traces, |$trace| $trace.rule)), |$rule| {
            LET $items = array::filter($traces, |$trace| $trace.rule = $rule);
            RETURN [$rule, { count: array::len($items), failed: array::len(fn::utils_engine_debug_failed($items)), total_duration: $total($items) }];
        }))
    };
}
COMMENT "Résume des traces de débogage : nombre, échecs, durée totale, et par règle { count, failed, total_duration }."
PERMISSIONS FULL;
