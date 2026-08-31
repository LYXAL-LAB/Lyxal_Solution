-- ============================================================================
-- TESTS — fn::security_key_derive
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_key_derive(
    "vault://keys/master",
    "tenant:acme:storage",
    <bytes>"salt",
    "hkdf-sha256",
    "vault://keys/derived/acme-storage"
);
