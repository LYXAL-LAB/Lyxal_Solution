-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_stats($samples:array<object>)->object{
 IF array::len($samples)=0{RETURN {count:0,min:NONE,max:NONE,average:NONE,total:0s};};
 LET $d=array::map($samples,|$s|$s.duration);
 LET $total=array::fold($d,0s,|$a,$x|$a+$x);
 RETURN {count:array::len($d),min:math::min($d),max:math::max($d),average:$total/array::len($d),total:$total};
}
COMMENT "Calcule les statistiques de durée."
PERMISSIONS FULL;
