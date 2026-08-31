-- ============================================================================
-- TESTS — fn::utils_array_rotate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_array_rotate(
    [1,2,3,4],
    1
);

RETURN fn::utils_array_rotate(
    [1,2,3,4],
    -1
);
