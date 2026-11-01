-- ============================================================================
-- TESTS — fn::validation_benchmark_success_rate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_success_rate(
    [
        {success:true},
        {success:true},
        {success:false}
    ]
);
