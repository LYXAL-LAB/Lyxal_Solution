-- ============================================================================
-- TESTS — fn::validation_optimizer_pipeline_cost
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_pipeline_cost([{rule:"required"},{rule:"pattern"}]);
