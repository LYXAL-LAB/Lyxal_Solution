-- ============================================================================
-- TESTS — fn::utils_first_not_none
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_first_not_none(
    [NONE,NULL,"Lyxal"]
);
