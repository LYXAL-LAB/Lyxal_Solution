-- ============================================================================
-- TESTS — fn::security_hmac_sign
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_sign(
    "POST\n/path\n123",
    "vault://webhooks/client-a",
    "hmac-sha256"
);
