-- ============================================================================
-- TESTS — fn::utils_array_chunk
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_array_chunk(
    [1,2,3,4,5],
    2
);

RETURN fn::utils_array_chunk(
    [1,2],
    0
);
