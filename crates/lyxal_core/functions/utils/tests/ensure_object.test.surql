-- ============================================================================
-- TESTS — fn::utils_ensure_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_ensure_object(NONE);
RETURN fn::utils_ensure_object({name:"Lyxal"});
