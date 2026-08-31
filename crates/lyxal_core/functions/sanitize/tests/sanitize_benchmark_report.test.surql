-- ============================================================================
-- TESTS — fn::sanitize_benchmark_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_report([{name:"run",wall_duration:1s,samples:[{duration:10ms,error_code:NONE}]}]);
