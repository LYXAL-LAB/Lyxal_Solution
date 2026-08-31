-- ============================================================================
-- TESTS — fn::sanitize_benchmark_compare
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_benchmark_compare({name:"a",samples:[{duration:20ms}]},{name:"b",samples:[{duration:10ms}]});
