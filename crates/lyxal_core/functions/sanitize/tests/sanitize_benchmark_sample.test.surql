-- ============================================================================
-- TESTS — fn::sanitize_benchmark_sample
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_sample("sanitize_user",10ms,true,NONE);
