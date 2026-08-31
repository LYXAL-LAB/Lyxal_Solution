-- ============================================================================
-- TESTS — fn::utils_runtime_environment
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_runtime_environment(
    "production",
    false,
    {region:"eu-west"}
);
