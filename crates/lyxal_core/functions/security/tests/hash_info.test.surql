-- ============================================================================
-- TESTS — fn::security_hash_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hash_info(
    crypto::sha256("Lyxal"),
    "sha256"
);
