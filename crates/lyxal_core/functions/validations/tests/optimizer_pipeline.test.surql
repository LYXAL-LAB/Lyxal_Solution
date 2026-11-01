-- ============================================================================
-- TESTS — fn::validation_optimizer_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_pipeline([{rule:"trim"},{rule:"trim"},{rule:"pattern"}]);
