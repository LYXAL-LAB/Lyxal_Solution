-- ============================================================================
-- TESTS — fn::security_signature_sign
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_sign(
    "canonical-content",
    "vault://keys/signing",
    "ed25519"
);
