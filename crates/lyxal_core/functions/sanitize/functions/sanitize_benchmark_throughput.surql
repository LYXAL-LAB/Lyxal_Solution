-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_throughput
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_throughput($count:int,$wall_duration:duration)->decimal{
 IF $count<0 OR $wall_duration<=0s{THROW "SANITIZE_BENCHMARK_INVALID_THROUGHPUT_INPUT";};
 RETURN type::decimal($count)/type::decimal(duration::secs($wall_duration));
}
COMMENT "Calcule le débit moyen par seconde."
PERMISSIONS FULL;
