-- ============================================================================
-- TESTS — fn::validation_benchmark_regression
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_regression(
    {
        samples:[
            {duration:10ms},
            {duration:10ms}
        ]
    },
    {
        samples:[
            {duration:13ms},
            {duration:13ms}
        ]
    },
    0.20dec
);
