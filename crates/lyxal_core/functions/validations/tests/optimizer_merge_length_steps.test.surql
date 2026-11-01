-- ============================================================================
-- TESTS — fn::validation_optimizer_merge_length_steps
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_merge_length_steps([{rule:"min_length",value:2},{rule:"min_length",value:5}]);
