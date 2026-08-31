-- ============================================================================
-- TESTS — fn::security_hash_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

LET $hash = crypto::argon2::generate("secret");
RETURN fn::security_hash_verify($hash, "secret", "argon2");

RETURN fn::security_hash_verify(
    crypto::sha256("Lyxal"),
    "Lyxal",
    "sha256"
);
