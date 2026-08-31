-- ============================================================================
-- TESTS — fn::utils_cache_key
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_cache_key(
    "scheduler",
    ["job",123,"v1"]
);
