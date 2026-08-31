-- ============================================================================
-- TESTS — fn::utils_cache_hash
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_hash(
    {
        key:"a",
        value:{name:"Lyxal"},
        expires_at:d"2026-08-03T13:00:00Z"
    }
);
