-- ============================================================================
-- TESTS — fn::utils_runtime_platform
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_runtime_platform(
    "surrealdb",
    "surrealql",
    "portable"
);
