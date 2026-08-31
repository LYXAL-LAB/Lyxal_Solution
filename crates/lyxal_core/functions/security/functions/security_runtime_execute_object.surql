-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_execute_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_execute_object(
    $compiled_schema:object,
    $payload:object,
    $context:option<object>
)->object{
 LET $results=array::map(
  object::entries($compiled_schema.compiled_fields),
  |$e|fn::security_runtime_execute_field(
   object::extend($e[1],{name:$e[0]}),
   $payload[$e[0]],
   $context
  )
 );
 RETURN {
  fields:$results,
  output:object::from_entries(array::map($results,|$r|[$r.field,$r.output])),
  findings:array::flatten(array::map($results,|$r|$r.findings)),
  decisions:array::flatten(array::map($results,|$r|$r.decisions))
 };
}
COMMENT "Exécute un schéma Security sur un objet."
PERMISSIONS FULL;
