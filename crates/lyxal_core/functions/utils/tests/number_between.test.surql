-- ============================================================================
-- TESTS — fn::utils_number_between
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_number_between(5,1,10,true);
RETURN fn::utils_number_between(1,1,10,false);
