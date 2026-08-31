-- ============================================================================
-- TESTS — fn::security_key_wrap
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_key_wrap(
    "vault://keys/data",
    "vault://keys/kek",
    "aes-kw"
);
