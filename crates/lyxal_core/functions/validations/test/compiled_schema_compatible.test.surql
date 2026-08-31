-- ============================================================================
-- TESTS — fn::validation_compiled_schema_compatible
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_compiled_schema_compatible(
 {fields:{name:[]}},
 {fields:{name:[],age:[]}}
);
