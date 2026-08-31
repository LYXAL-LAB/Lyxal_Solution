-- ============================================================================
-- TESTS — fn::security_step
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_step({rule:"detect_payload"},"STEP");
