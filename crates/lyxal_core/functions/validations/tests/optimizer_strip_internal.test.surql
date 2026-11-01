-- ============================================================================
-- TESTS — fn::validation_optimizer_strip_internal
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_optimizer_strip_internal([{rule:"trim",_weight:30}]);
