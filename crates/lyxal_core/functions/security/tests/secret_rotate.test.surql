-- ============================================================================
-- TESTS — fn::security_secret_rotate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_rotate(
    "vault://client/current",
    "vault://client/next",
    d"2026-08-10T00:00:00Z",
    24h
);
