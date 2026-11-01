-- ============================================================================
-- TESTS — fn::validation_schema_cache_match
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_match(
    {
        cache_key:"user@v1:aabbccdd",
        expires_at:d"2026-08-03T15:00:00Z"
    },
    "user@v1:aabbccdd",
    d"2026-08-03T14:00:00Z"
);
