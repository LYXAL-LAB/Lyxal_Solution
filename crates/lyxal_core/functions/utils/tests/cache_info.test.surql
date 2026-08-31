-- ============================================================================
-- TESTS — fn::utils_cache_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_info(
    {
        key:"a",
        value:{name:"Lyxal"},
        created_at:d"2026-08-03T12:00:00Z",
        updated_at:d"2026-08-03T12:00:00Z",
        expires_at:d"2026-08-03T13:00:00Z",
        hits:2
    },
    d"2026-08-03T12:30:00Z"
);
