-- ============================================================================
-- TESTS — fn::validation_benchmark_percentile
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_percentile(
    [
        {duration:10ms},
        {duration:20ms},
        {duration:30ms},
        {duration:40ms}
    ],
    95
);
