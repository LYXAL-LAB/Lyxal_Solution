-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_batch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_batch(
    $compiled_schema:object,
    $payloads:array<object>,
    $context:option<object>
)->object{
 LET $results=array::map($payloads,|$p|fn::security_runtime_execute_object($compiled_schema,$p,$context));
 RETURN {total:array::len($results),results:$results};
}
COMMENT "Exécute un schéma Security sur un lot."
PERMISSIONS FULL;
