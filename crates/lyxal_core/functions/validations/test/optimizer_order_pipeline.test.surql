-- ============================================================================
-- TESTS — fn::validation_optimizer_order_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_order_pipeline([{rule:"pattern"},{rule:"trim"},{rule:"required"}]);
