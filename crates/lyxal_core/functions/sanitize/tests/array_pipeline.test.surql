-- ============================================================================
-- TESTS — fn::sanitize_array_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_array_pipeline(
    [NONE,"A","A","B"],
    true,
    true,
    2
);
