-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_batch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_batch(
 $compiled_schema:object,$payloads:array<object>,$max_steps:int
) -> object {
 LET $results=array::map($payloads,|$payload|fn::validation_runtime_execute_object($compiled_schema,$payload,$max_steps));
 RETURN {total:array::len($results),valid_count:array::len(array::filter($results,|$r|$r.valid)),results:$results};
}
COMMENT "Exécute un schéma compilé sur un lot."
PERMISSIONS FULL;
