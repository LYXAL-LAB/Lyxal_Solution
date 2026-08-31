-- ============================================================================
-- TESTS — fn::security_token_sign
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_token_sign(
    {sub:"user:123"},
    "vault://keys/token-signing",
    "ed25519",
    "jwt"
);
