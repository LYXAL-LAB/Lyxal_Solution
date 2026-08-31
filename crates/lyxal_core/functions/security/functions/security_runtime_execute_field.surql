-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_execute_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_execute_field(
    $compiled_field:object,
    $value:any,
    $context:option<object>
)->object{
 LET $execution=fn::security_pipeline_execute($value,$compiled_field.steps,$context);
 RETURN {
  field:$compiled_field.name,
  input:$value,
  output:$execution.value,
  findings:$execution.findings,
  decisions:$execution.decisions
 };
}
COMMENT "Exécute un champ compilé dans le Security Runtime."
PERMISSIONS FULL;
