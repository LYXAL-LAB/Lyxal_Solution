-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_benchmark_compare.surql
-- Fonction : fn::utils_engine_benchmark_compare
--
-- Compare deux statistiques de mesure (fn::utils_engine_benchmark_stats) :
-- rapports candidat / référence de la moyenne et du p95 ; regression si l'un
-- dépasse 1 + $max_regression_ratio (ex. 0.1 = 10 % plus lent).
--
-- Paramètres
--   $baseline             : object
--   $candidate            : object
--   $max_regression_ratio : number
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_regression_ratio négatif
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_benchmark_compare(
    $baseline: object,
    $candidate: object,
    $max_regression_ratio: number
) -> object {
    IF $max_regression_ratio < 0 { THROW "CORE_INVALID_ARGUMENT"; };
    LET $ratio = |$left: option<duration>, $right: option<duration>|
        IF $left IS NONE OR $right IS NONE OR duration::nanos($left) = 0 { NONE } ELSE { type::float(duration::nanos($right)) / type::float(duration::nanos($left)) };
    LET $average_ratio = $ratio($baseline.average, $candidate.average);
    LET $p95_ratio = $ratio($baseline.p95, $candidate.p95);
    RETURN {
        average_ratio: $average_ratio,
        p95_ratio: $p95_ratio,
        regression: ($average_ratio IS NOT NONE AND $average_ratio > 1 + $max_regression_ratio)
            OR ($p95_ratio IS NOT NONE AND $p95_ratio > 1 + $max_regression_ratio)
    };
}
COMMENT "Compare deux statistiques de mesure (fn::utils_engine_benchmark_stats) : rapports candidat / référence de la moyenne et du p95 ; regression si l'un dépasse 1 + $max_regression_ratio (ex. 0.1 = 10 % plus lent)."
PERMISSIONS FULL;
