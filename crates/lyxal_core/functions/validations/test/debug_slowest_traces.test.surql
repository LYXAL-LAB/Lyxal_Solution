-- ============================================================================
-- TESTS — fn::validation_debug_slowest_traces
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_slowest_traces({traces:[{rule:"trim",duration:1ms},{rule:"pattern",duration:5ms}]},1);
