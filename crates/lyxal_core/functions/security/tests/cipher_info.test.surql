-- ============================================================================
-- TESTS — fn::security_cipher_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Contrat descriptif aligné sur lyxal_crypto (AES-256-GCM / HKDF-SHA256)
RETURN fn::security_cipher_info();
