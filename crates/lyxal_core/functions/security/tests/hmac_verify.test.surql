-- ============================================================================
-- TESTS — fn::security_hmac_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_verify(
    "POST\n/path\n123",
    "base64-signature",
    "vault://webhooks/client-a",
    "hmac-sha256"
);
