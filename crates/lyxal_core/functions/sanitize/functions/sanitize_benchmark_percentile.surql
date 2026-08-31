-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_percentile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_percentile($samples:array<object>,$percentile:int)->option<duration>{
 IF $percentile<0 OR $percentile>100{THROW "SANITIZE_BENCHMARK_INVALID_PERCENTILE";};
 IF array::len($samples)=0{RETURN NONE;};
 LET $d=array::sort::asc(array::map($samples,|$s|$s.duration));
 LET $i=type::int(math::floor(type::float(array::len($d)-1)*type::float($percentile)/100f));
 RETURN $d[$i];
}
COMMENT "Calcule un percentile discret."
PERMISSIONS FULL;
