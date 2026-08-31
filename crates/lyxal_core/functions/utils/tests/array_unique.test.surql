-- ============================================================================
-- TESTS — fn::utils_array_unique
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_array_unique(
    ["a","a","b","c","b"]
);
