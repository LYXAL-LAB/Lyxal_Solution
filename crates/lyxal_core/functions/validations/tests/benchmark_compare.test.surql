-- ============================================================================
-- TESTS — fn::validation_benchmark_compare
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_compare(
    {
        name:"baseline",
        samples:[
            {duration:20ms},
            {duration:22ms}
        ]
    },
    {
        name:"optimized",
        samples:[
            {duration:10ms},
            {duration:12ms}
        ]
    }
);
