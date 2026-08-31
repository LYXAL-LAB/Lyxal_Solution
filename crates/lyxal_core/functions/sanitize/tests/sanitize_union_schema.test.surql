-- ============================================================================
-- TESTS — fn::sanitize_union_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_union_schema(
 [{name:"a"},{name:"b"}],
 "type"
);
