-- ============================================================================
-- TESTS — fn::validation_optimizer_step_cost
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_step_cost({rule:"trim"});
RETURN fn::validation_optimizer_step_cost({rule:"pattern"});
