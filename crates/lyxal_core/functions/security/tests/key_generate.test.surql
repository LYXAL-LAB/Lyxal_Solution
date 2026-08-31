-- ============================================================================
-- TESTS — fn::security_key_generate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_key_generate(
    "ed25519",
    "vault://keys/signing",
    ["sign","verify"]
);
