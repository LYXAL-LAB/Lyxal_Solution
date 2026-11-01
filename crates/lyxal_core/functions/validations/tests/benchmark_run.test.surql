-- ============================================================================
-- TESTS — fn::validation_benchmark_run
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_run(
    "user_validation",
    [
        {duration:10ms,success:true},
        {duration:12ms,success:true}
    ],
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T12:00:01Z"
);
