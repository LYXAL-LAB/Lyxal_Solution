-- ============================================================================
-- TESTS — fn::validation_schema_cache_entry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_entry(
    "user@v1:aabbccdd",
    {name:"user",version:"v1",fields:{}},
    1h,
    d"2026-08-03T12:00:00Z"
);
