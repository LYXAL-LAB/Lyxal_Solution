-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_debug_rule_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_debug_rule_stats($session:object,$rule:string)->object{
 LET $clean=string::lowercase(string::trim($rule));
 LET $traces=array::filter($session.traces,|$t|$t.rule=$clean);
 LET $failed=array::filter($traces,|$t|$t.success=false);
 RETURN {rule:$clean,executions:array::len($traces),failures:array::len($failed),successes:array::len($traces)-array::len($failed)};
}
COMMENT "Retourne les statistiques d'une règle."
PERMISSIONS FULL;
