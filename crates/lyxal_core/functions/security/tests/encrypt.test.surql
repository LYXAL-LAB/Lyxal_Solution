-- ============================================================================
-- TESTS — fn::security_encrypt
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_encrypt(
    <bytes>"Lyxal",
    "vault://keys/data",
    "aes-256-gcm",
    NONE
);
