-- ============================================================================
-- TESTS — fn::sanitize_benchmark_regression
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_regression({samples:[{duration:10ms}]},{samples:[{duration:13ms}]},0.2dec);
