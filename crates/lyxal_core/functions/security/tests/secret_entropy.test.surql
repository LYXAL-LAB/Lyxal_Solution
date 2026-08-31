-- ============================================================================
-- TESTS — fn::security_secret_entropy
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_entropy(
    "Abcdef123456!XYZ"
);
