-- ============================================================================
-- TESTS — fn::utils_is_empty
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_is_empty("");
RETURN fn::utils_is_empty([]);
RETURN fn::utils_is_empty({});
