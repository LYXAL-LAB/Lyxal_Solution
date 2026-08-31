-- ============================================================================
-- TESTS — fn::sanitize_step
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_step({rule:"trim"},"STEP");
RETURN fn::sanitize_step({rule:"unknown"},"STEP");
