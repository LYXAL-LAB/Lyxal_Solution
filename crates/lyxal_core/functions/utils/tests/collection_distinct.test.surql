-- ============================================================================
-- TESTS — fn::utils_collection_distinct
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_distinct(
    ["a","a","b"]
);
