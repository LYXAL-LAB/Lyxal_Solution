-- ============================================================================
-- TESTS — fn::security_optimizer_step
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_step({rule:"detect_payload"});
