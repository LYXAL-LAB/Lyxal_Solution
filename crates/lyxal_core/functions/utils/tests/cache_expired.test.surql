-- ============================================================================
-- TESTS — fn::utils_cache_expired
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_expired(
    {expires_at:d"2026-08-03T10:00:00Z"},
    d"2026-08-03T12:00:00Z"
);
