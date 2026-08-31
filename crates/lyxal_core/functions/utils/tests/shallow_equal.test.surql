-- ============================================================================
-- TESTS — fn::utils_shallow_equal
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_shallow_equal(
    {a:1,b:2},
    {b:2,a:1}
);
