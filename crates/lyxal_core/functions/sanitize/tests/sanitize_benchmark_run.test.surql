-- ============================================================================
-- TESTS — fn::sanitize_benchmark_run
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_run("run",[ {duration:10ms,changed:true} ],1s);
