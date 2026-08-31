-- ============================================================================
-- TESTS — fn::validation_benchmark_sample
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_benchmark_sample(
    "validate_user",
    12ms,
    true,
    {schema:"user@v1"}
);

-- Erreur attendue : VALIDATION_BENCHMARK_INVALID_DURATION
RETURN fn::validation_benchmark_sample(
    "validate_user",
    -1ms,
    true,
    NONE
);
