-- ============================================================================
-- TESTS — fn::sanitize_benchmark_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_stats([{duration:10ms},{duration:20ms}]);
