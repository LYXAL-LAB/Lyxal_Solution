-- ============================================================================
-- TESTS — fn::utils_compare_strings
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_compare_strings(
    " Lyxal ",
    "lyxal",
    false,
    true
);
