-- ============================================================================
-- TESTS — fn::validation_dsl_rule
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_rule(
    "min_length",
    3
);
