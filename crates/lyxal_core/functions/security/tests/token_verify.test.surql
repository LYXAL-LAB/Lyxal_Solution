-- ============================================================================
-- TESTS — fn::security_token_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_verify(
    "vault://tokens/token-1",
    "candidate-token",
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T13:00:00Z",
    "active"
);
