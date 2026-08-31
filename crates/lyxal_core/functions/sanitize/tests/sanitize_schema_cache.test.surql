-- ============================================================================
-- TESTS — fn::sanitize_schema_cache
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_schema_cache(
 {name:"user",version:"v1",compiled_fields:{}},
 1h,
 d"2026-08-03T12:00:00Z"
);
