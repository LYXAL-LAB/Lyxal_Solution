-- ============================================================================
-- TESTS — fn::security_secret_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_validate(
    "abc123XYZ!",
    8,
    128
);
