-- ============================================================================
-- TESTS — fn::sanitize_optimizer_order
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_order([{rule:"slug"},{rule:"trim"},{rule:"default"}]);
