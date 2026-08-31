-- ============================================================================
-- TESTS — fn::security_hash_string
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hash_string("Lyxal", "blake3");
