-- ============================================================================
-- TESTS — fn::security_decrypt
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Algorithme supporté (aes-256-gcm)
RETURN fn::security_decrypt(
    <bytes>"cipher",
    <bytes>"nonce",
    <bytes>"tag",
    "vault://keys/data",
    "aes-256-gcm",
    NONE
);

-- TEST 2 — Algorithme hors scope (xchacha20-poly1305)
-- Erreur attendue : SECURITY_UNSUPPORTED_CIPHER
RETURN fn::security_decrypt(
    <bytes>"cipher",
    <bytes>"nonce",
    <bytes>"tag",
    "vault://keys/data",
    "xchacha20-poly1305",
    NONE
);
