-- ============================================================================
-- TESTS — fn::validation_compiled_schema_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compiled_schema_info(
 {name:"user",version:"v1",fields:{name:[]},compiled_at:time::now()}
);
