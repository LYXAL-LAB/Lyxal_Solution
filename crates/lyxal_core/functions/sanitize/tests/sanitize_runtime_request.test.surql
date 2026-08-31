-- ============================================================================
-- TESTS — fn::sanitize_runtime_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_request(
 {schema_name:"user"},
 {name:" Lyxal "},
 "req-001",
 NONE
);
