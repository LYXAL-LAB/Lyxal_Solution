-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_failed_traces
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_failed_traces($session:object)->array<object>{
 RETURN array::filter($session.traces,|$t|$t.success=false);
}
COMMENT "Retourne les traces échouées."
PERMISSIONS FULL;
