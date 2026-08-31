-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_summary
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_summary($session:object)->object{
 LET $failed=fn::validation_debug_failed_traces($session);
 RETURN {request_id:$session.request_id,schema_name:$session.schema_name,enabled:$session.enabled,trace_count:array::len($session.traces),failed_count:array::len($failed),success_count:array::len($session.traces)-array::len($failed),started_at:$session.started_at};
}
COMMENT "Produit le résumé d'une session."
PERMISSIONS FULL;
