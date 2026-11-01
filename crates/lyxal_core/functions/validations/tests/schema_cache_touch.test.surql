-- ============================================================================
-- TESTS — fn::validation_schema_cache_touch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_touch(
    {
        cache_key:"user@v1:aabbccdd",
        expires_at:d"2026-08-03T13:00:00Z"
    },
    2h,
    d"2026-08-03T12:30:00Z"
);
