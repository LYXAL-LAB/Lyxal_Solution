-- ============================================================================
-- TESTS — fn::sanitize_optimizer_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_validate([{rule:"trim"},{rule:"lowercase"}]);
RETURN fn::sanitize_optimizer_validate([{rule:"lowercase"},{rule:"uppercase"}]);
