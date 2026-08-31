-- ============================================================================
-- TESTS — fn::sanitize_benchmark_success_rate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_success_rate([{error_code:NONE},{error_code:"X"}]);
