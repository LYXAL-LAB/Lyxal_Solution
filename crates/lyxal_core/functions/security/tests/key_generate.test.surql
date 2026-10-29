-- ============================================================================
-- TESTS — fn::security_key_generate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_key_generate(
    "aes-256-gcm",
    "vault://keys/encryption",
    ["encrypt","decrypt"]
);

-- Erreur attendue : SECURITY_UNSUPPORTED_KEY_ALGORITHM
RETURN fn::security_key_generate(
    "ed25519",
    "vault://keys/signing",
    ["sign","verify"]
);
