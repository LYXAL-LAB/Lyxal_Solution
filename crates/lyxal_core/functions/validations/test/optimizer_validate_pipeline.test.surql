-- ============================================================================
-- TESTS — fn::validation_optimizer_validate_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_validate_pipeline([{rule:"trim"},{rule:"lowercase"}]);
RETURN fn::validation_optimizer_validate_pipeline([{rule:"lowercase"},{rule:"uppercase"}]);
