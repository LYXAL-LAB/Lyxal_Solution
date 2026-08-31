-- ============================================================================
-- TESTS — fn::utils_ensure_bool
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_ensure_bool("yes",false);
RETURN fn::utils_ensure_bool(0,true);
