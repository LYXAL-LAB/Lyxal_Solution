-- ============================================================================
-- TESTS — fn::security_benchmark_run
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_benchmark_run(
    "run",
    [{duration:10ms,blocked:false,score:0}],
    1s
);
