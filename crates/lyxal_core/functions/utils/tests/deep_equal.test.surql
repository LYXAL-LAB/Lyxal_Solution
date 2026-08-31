-- ============================================================================
-- TESTS — fn::utils_deep_equal
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_deep_equal(
    {a:[1,2],b:{c:true}},
    {a:[1,2],b:{c:true}}
);
