-- ============================================================================
-- TESTS — fn::security_hash_compare
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hash_compare(
    crypto::sha256("A"),
    crypto::sha256("A")
);
