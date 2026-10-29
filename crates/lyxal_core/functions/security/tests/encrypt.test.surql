-- ============================================================================
-- TESTS — fn::security_encrypt
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

-- TEST 1 — Algorithme supporté (aes-256-gcm)
RETURN fn::security_encrypt(
    <bytes>"Lyxal",
    "vault://keys/data",
    "aes-256-gcm",
    NONE
);

-- TEST 2 — Algorithme hors scope (chacha20-poly1305)
-- Erreur attendue : SECURITY_UNSUPPORTED_CIPHER
RETURN fn::security_encrypt(
    <bytes>"Lyxal",
    "vault://keys/data",
    "chacha20-poly1305",
    NONE
);
