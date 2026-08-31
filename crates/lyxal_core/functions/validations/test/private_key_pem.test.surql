-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/private_key_pem.test.surql
-- Fonction     : fn::validation_private_key_pem
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — PKCS#8
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_private_key_pem(
    "-----BEGIN PRIVATE KEY-----\nQUJDRA==\n-----END PRIVATE KEY-----",
    "PRIVATE_KEY",
    false,
    32768
);

-- ============================================================================
-- TEST 2 — Clé chiffrée autorisée
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_private_key_pem(
    "-----BEGIN ENCRYPTED PRIVATE KEY-----\nQUJDRA==\n-----END ENCRYPTED PRIVATE KEY-----",
    "PRIVATE_KEY",
    true,
    32768
);

-- ============================================================================
-- TEST 3 — Clé chiffrée interdite
-- Erreur attendue : PRIVATE_KEY_ENCRYPTED_KEY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_private_key_pem(
    "-----BEGIN ENCRYPTED PRIVATE KEY-----\nQUJDRA==\n-----END ENCRYPTED PRIVATE KEY-----",
    "PRIVATE_KEY",
    false,
    32768
);
