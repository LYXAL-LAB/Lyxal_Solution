-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_response
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_response(
    $request:object,
    $execution:object,
    $completed_at:datetime
)->object{
 LET $blocked=array::any($execution.decisions,|$d|$d.allowed=false);
 LET $score=fn::security_detect_score($execution.findings);
 RETURN {
  request_id:$request.request_id,
  schema_name:$request.context.schema_name,
  schema_version:$request.context.schema_version,
  blocked:$blocked,
  score:$score,
  findings:$execution.findings,
  decisions:$execution.decisions,
  output:$execution.output,
  started_at:$request.context.started_at,
  completed_at:$completed_at
 };
}
COMMENT "Construit la réponse publique du Security Runtime."
PERMISSIONS FULL;
