-- ============================================================================
-- TESTS — fn::sanitize_optimizer_cost
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_cost([{rule:"trim"},{rule:"slug"}]);
