-- ============================================================================
-- TESTS — fn::security_benchmark_percentile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_benchmark_percentile(
    [{duration:10ms},{duration:20ms},{duration:30ms}],
    95
);
