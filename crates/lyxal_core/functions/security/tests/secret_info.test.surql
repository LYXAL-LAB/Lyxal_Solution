-- ============================================================================
-- TESTS — fn::security_secret_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_info(
    "vault://client/api-key",
    d"2026-08-01T00:00:00Z",
    NONE,
    "active"
);
