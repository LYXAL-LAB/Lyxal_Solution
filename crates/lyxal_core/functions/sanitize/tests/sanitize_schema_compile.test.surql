-- ============================================================================
-- TESTS — fn::sanitize_schema_compile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_schema_compile(
 {
  name:"user",
  version:"v1",
  fields:{name:{pipeline:[{rule:"trim"}]}}
 },
 10
);
