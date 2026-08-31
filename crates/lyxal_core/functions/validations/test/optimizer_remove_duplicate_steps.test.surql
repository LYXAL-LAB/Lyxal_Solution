-- ============================================================================
-- TESTS — fn::validation_optimizer_remove_duplicate_steps
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_remove_duplicate_steps([{rule:"trim"},{rule:"trim"}]);
