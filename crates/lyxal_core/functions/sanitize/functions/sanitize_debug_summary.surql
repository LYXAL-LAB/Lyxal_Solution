-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_summary
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_summary($session:object)->object{
 LET $changed=array::filter($session.traces,|$t|$t.changed=true);
 RETURN {request_id:$session.request_id,schema_name:$session.schema_name,trace_count:array::len($session.traces),changed_count:array::len($changed),unchanged_count:array::len($session.traces)-array::len($changed),started_at:$session.started_at};
}
COMMENT "Produit le résumé d'une session."
PERMISSIONS FULL;
