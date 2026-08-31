-- ============================================================================
-- TESTS — fn::utils_runtime_execution_time
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_runtime_execution_time(
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T12:00:01Z"
);
