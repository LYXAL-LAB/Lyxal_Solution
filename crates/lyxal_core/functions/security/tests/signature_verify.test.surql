-- ============================================================================
-- TESTS — fn::security_signature_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_verify(
    "canonical-content",
    "base64-signature",
    "vault://keys/signing-public",
    "ed25519"
);
