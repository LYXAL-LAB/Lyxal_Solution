-- ============================================================================
-- TESTS — fn::validation_schema_cache_prune
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_prune(
    [
        {cache_key:"a",expires_at:d"2026-08-03T10:00:00Z"},
        {cache_key:"b",expires_at:d"2026-08-03T20:00:00Z"}
    ],
    d"2026-08-03T12:00:00Z"
);
