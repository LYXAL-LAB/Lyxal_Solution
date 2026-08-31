-- ============================================================================
-- TESTS — fn::sanitize_benchmark_summary
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_summary({name:"run",wall_duration:1s,samples:[{duration:10ms,error_code:NONE}]});
