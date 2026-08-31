-- ============================================================================
-- TESTS — fn::security_encrypt_string
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_encrypt_string(
    "Lyxal",
    "vault://keys/data",
    "aes-256-gcm",
    "user:123"
);
