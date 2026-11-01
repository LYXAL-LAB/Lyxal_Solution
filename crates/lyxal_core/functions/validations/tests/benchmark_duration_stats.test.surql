-- ============================================================================
-- TESTS — fn::validation_benchmark_duration_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_duration_stats(
    [
        {duration:10ms},
        {duration:20ms},
        {duration:30ms}
    ]
);
