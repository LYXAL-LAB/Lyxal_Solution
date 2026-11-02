-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_benchmark_report.surql
-- Fonction : fn::utils_engine_benchmark_report
--
-- Rapport d'une campagne de mesure : statistiques et, si des statistiques de
-- référence sont fournies, comparaison (fn::utils_engine_benchmark_compare).
--
-- Paramètres
--   $run                  : object
--   $baseline             : option<object>
--   $max_regression_ratio : number
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_benchmark_report(
    $run: object,
    $baseline: option<object>,
    $max_regression_ratio: number
) -> object {
    LET $stats = fn::utils_engine_benchmark_stats($run);
    RETURN {
        name: $run.name,
        wall_duration: $run.wall_duration,
        stats: $stats,
        comparison: IF $baseline IS NONE { NONE } ELSE { fn::utils_engine_benchmark_compare($baseline, $stats, $max_regression_ratio) },
        generated_at: time::now()
    };
}
COMMENT "Rapport d'une campagne de mesure : statistiques et, si des statistiques de référence sont fournies, comparaison (fn::utils_engine_benchmark_compare)."
PERMISSIONS FULL;
