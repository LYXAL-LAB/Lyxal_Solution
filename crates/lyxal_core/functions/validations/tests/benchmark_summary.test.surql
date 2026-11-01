-- ============================================================================
-- TESTS — fn::validation_benchmark_summary
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_summary(
    {
        name:"user_validation",
        wall_duration:1s,
        samples:[
            {duration:10ms,success:true},
            {duration:20ms,success:true}
        ]
    }
);
