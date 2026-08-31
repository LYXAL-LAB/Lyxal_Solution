-- ============================================================================
-- TESTS — fn::security_decrypt
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_decrypt(
    <bytes>"cipher",
    <bytes>"nonce",
    <bytes>"tag",
    "vault://keys/data",
    "aes-256-gcm",
    NONE
);
