-- ============================================================================
-- TESTS — fn::security_hash_fingerprint
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hash_fingerprint(
    crypto::sha256("Lyxal"),
    4,
    ":"
);
