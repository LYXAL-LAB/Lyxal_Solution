-- ============================================================================
-- TESTS — fn::security_secret_import
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_secret_import(
    "vault://client/api-key",
    "secret-value",
    {owner:"client-a"}
);
