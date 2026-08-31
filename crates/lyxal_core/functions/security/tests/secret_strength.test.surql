-- ============================================================================
-- TESTS — fn::security_secret_strength
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_strength(
    "Abcdef123456!XYZ"
);
