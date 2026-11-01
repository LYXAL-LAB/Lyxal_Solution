-- ============================================================================
-- TESTS — fn::validation_benchmark_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_report(
    [
        {
            name:"baseline",
            wall_duration:1s,
            samples:[
                {duration:10ms,success:true}
            ]
        },
        {
            name:"optimized",
            wall_duration:1s,
            samples:[
                {duration:5ms,success:true}
            ]
        }
    ]
);
