-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_schema_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_schema_compile(
    $schema:object,
    $max_steps:int
)->object{
 LET $compiled_fields=object::from_entries(
  array::map(
   object::entries($schema.fields),
   |$e|[
    $e[0],
    fn::security_pipeline_compile(
     $e[1].pipeline,
     string::concat($schema.name,"::",$e[0]),
     $schema.version,
     $max_steps
    )
   ]
  )
 );
 RETURN object::extend($schema,{compiled_fields:$compiled_fields,compiled_at:time::now()});
}
COMMENT "Compile tous les pipelines d'un schéma Security."
PERMISSIONS FULL;
