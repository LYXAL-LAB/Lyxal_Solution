-- ============================================================================
-- TESTS — fn::security_hmac_signature_header
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_signature_header(
    "hmac-sha256",
    "client-a",
    d"2026-08-03T12:00:00Z",
    "nonce123456789012",
    "signature"
);
