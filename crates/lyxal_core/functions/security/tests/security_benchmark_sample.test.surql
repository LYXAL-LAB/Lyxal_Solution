-- ============================================================================
-- TESTS — fn::security_benchmark_sample
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_benchmark_sample(
    "security_request",
    10ms,
    false,
    0,
    NONE
);
