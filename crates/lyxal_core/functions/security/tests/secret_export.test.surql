-- ============================================================================
-- TESTS — fn::security_secret_export
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_export(
    "vault://client/api-key",
    "migration",
    d"2026-08-03T13:00:00Z"
);
