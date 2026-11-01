-- ============================================================================
-- TESTS — fn::validation_schema_cache_invalidate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_invalidate(
    [
        {cache_key:"user@v1:aaaa"},
        {cache_key:"user@v2:bbbb"},
        {cache_key:"team@v1:cccc"}
    ],
    "user"
);
