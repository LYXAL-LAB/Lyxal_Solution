-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_stats(
    $responses:array<object>
)->object{
 RETURN {
  total:array::len($responses),
  blocked:array::len(array::filter($responses,|$r|$r.blocked=true)),
  allowed:array::len(array::filter($responses,|$r|$r.blocked=false)),
  average_score:IF array::len($responses)=0{0f}ELSE{array::fold($responses,0,|$n,$r|$n+$r.score)/array::len($responses)}
 };
}
COMMENT "Calcule les statistiques du Security Runtime."
PERMISSIONS FULL;
