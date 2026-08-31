-- ============================================================================
-- TESTS — fn::security_benchmark_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_benchmark_report([
    {
        name:"run",
        wall_duration:1s,
        samples:[
            {duration:10ms,blocked:false,score:0}
        ]
    }
]);
