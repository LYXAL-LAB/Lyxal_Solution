-- ============================================================================
-- TESTS — fn::sanitize_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_schema(
 "user",
 "v1",
 {name:{pipeline:[{rule:"trim"}]}},
 "strip"
);
