-- ============================================================================
-- TESTS — fn::sanitize_nested_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_nested_schema(
 "address",
 {name:"address",version:"v1",fields:{}},
 false
);
