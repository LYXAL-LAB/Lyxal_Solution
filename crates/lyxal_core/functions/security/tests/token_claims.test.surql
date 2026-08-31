-- ============================================================================
-- TESTS — fn::security_token_claims
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_claims(
    "user:123",
    ["lyxal-api"],
    ["read","write"],
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T13:00:00Z",
    {tenant:"acme"}
);
