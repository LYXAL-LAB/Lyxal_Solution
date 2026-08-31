-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_health
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_health(
 $registry_entries:array<object>,$cache_entries:array<object>,$now:datetime
) -> object {
 LET $active=array::filter($registry_entries,|$entry|$entry.status="active");
 RETURN {healthy:true,active_schema_count:array::len($active),cache:fn::validation_schema_cache_stats($cache_entries,$now),checked_at:$now};
}
COMMENT "Retourne l'état synthétique du Validation Runtime."
PERMISSIONS FULL;
