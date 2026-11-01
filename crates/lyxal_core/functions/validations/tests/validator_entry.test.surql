-- ============================================================================
-- TESTS — fn::validation_validator_entry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_entry(
    "validation::email",
    "v1",
    "format",
    "validation::email",
    true
);
