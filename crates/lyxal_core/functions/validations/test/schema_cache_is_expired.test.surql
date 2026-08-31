-- ============================================================================
-- TESTS — fn::validation_schema_cache_is_expired
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_is_expired(
    {expires_at:d"2026-08-03T13:00:00Z"},
    d"2026-08-03T14:00:00Z"
);
