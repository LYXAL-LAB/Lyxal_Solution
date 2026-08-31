-- ============================================================================
-- TESTS — fn::utils_number_format
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_number_format(
    1234567.8f,
    2,
    ",",
    " "
);
