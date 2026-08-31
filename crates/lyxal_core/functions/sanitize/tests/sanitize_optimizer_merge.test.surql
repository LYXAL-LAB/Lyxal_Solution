-- ============================================================================
-- TESTS — fn::sanitize_optimizer_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_merge([{rule:"trim"}],[{rule:"trim"},{rule:"lowercase"}]);
