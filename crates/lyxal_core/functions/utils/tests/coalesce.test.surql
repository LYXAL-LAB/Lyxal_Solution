-- ============================================================================
-- TESTS — fn::utils_coalesce
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_coalesce(
    [NONE,NULL,"Lyxal","Core"]
);
