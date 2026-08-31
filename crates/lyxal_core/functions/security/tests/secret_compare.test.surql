-- ============================================================================
-- TESTS — fn::security_secret_compare
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_compare(
    "vault://api/client-a",
    "candidate-secret"
);
