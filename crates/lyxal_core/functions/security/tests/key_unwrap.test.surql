-- ============================================================================
-- TESTS — fn::security_key_unwrap
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_key_unwrap(
    <bytes>"wrapped-key",
    "vault://keys/kek",
    "aes-256-gcm",
    "vault://keys/data-restored"
);

-- Erreur attendue : SECURITY_UNSUPPORTED_KEY_WRAP_ALGORITHM
RETURN fn::security_key_unwrap(
    <bytes>"wrapped-key",
    "vault://keys/kek",
    "aes-kw",
    "vault://keys/data-restored"
);
