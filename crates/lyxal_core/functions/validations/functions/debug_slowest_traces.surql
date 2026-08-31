-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_slowest_traces
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_slowest_traces($session:object,$limit:int)->array<object>{
 IF $limit<1{THROW "VALIDATION_DEBUG_INVALID_LIMIT";};
 RETURN array::slice(array::sort::desc($session.traces,"duration"),0,$limit);
}
COMMENT "Retourne les traces les plus lentes."
PERMISSIONS FULL;
