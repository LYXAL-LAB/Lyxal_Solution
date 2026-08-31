-- ============================================================================
-- TESTS — fn::security_benchmark_block_rate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_benchmark_block_rate(
    [{blocked:true},{blocked:false},{blocked:true}]
);
