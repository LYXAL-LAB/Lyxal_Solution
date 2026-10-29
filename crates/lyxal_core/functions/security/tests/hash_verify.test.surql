-- ============================================================================
-- TESTS — fn::security_hash_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hash_verify(
    crypto::sha256("Lyxal"),
    "Lyxal",
    "sha256"
);

RETURN fn::security_hash_verify(
    crypto::blake3("Lyxal"),
    "Lyxal",
    "blake3"
);

-- Erreur attendue : SECURITY_NATIVE_PASSWORD_VERIFY_REQUIRED
RETURN fn::security_hash_verify("hash", "secret", "argon2");
