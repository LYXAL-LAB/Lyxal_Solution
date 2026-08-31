-- ============================================================================
-- TESTS — fn::utils_compare_arrays
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_compare_arrays(
    [1,2,3],
    [3,2,1],
    true
);
