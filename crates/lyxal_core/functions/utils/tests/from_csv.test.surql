-- ============================================================================
-- TESTS — fn::utils_from_csv
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_from_csv(
    "name,version\nLyxal,1\nCore,2",
    ",",
    true
);
