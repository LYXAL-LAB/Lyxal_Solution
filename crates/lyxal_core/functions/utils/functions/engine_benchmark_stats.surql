-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_benchmark_stats.surql
-- Fonction : fn::utils_engine_benchmark_stats
--
-- Statistiques d'une campagne de mesure : nombre d'échantillons, taux de
-- réussite, min, max, moyenne, centiles p50 / p95 / p99 (rang inférieur) et
-- débit (échantillons par seconde sur la durée totale ; NONE si elle est
-- nulle).
--
-- Paramètres
--   $run : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_benchmark_stats(
    $run: object
) -> object {
    LET $count = array::len($run.samples);
    IF $count = 0 {
        RETURN { sample_count: 0, success_rate: NONE, min: NONE, max: NONE, average: NONE, p50: NONE, p95: NONE, p99: NONE, throughput: NONE };
    };
    LET $nanos = array::sort::asc(array::map($run.samples, |$sample| duration::nanos($sample.duration)));
    LET $percentile = |$p: int| duration::from_nanos($nanos[type::int(math::floor(type::float($count - 1) * type::float($p) / 100f))]);
    LET $wall = duration::nanos($run.wall_duration);
    RETURN {
        sample_count: $count,
        success_rate: type::float(array::len(array::filter($run.samples, |$sample| $sample.ok))) / type::float($count),
        min: duration::from_nanos($nanos[0]),
        max: duration::from_nanos($nanos[$count - 1]),
        average: duration::from_nanos(math::sum($nanos) / $count),
        p50: $percentile(50),
        p95: $percentile(95),
        p99: $percentile(99),
        throughput: IF $wall = 0 { NONE } ELSE { type::float($count) * 1000000000f / type::float($wall) }
    };
}
COMMENT "Statistiques d'une campagne de mesure : nombre d'échantillons, taux de réussite, min, max, moyenne, centiles p50 / p95 / p99 (rang inférieur) et débit (échantillons par seconde sur la durée totale ; NONE si elle est nulle)."
PERMISSIONS FULL;
