-- ============================================================================
-- TESTS — fn::validation_validator_name
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_validator_name(
    "validation::email",
    "VALIDATOR_NAME"
);
