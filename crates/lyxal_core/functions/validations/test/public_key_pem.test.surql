-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/public_key_pem.test.surql
-- Fonction     : fn::validation_public_key_pem
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Clé publique générique
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_public_key_pem(
    "-----BEGIN PUBLIC KEY-----\nQUJDRA==\n-----END PUBLIC KEY-----",
    "PUBLIC_KEY",
    16384
);

-- ============================================================================
-- TEST 2 — Clé RSA publique
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_public_key_pem(
    "-----BEGIN RSA PUBLIC KEY-----\nQUJDRA==\n-----END RSA PUBLIC KEY-----",
    "PUBLIC_KEY",
    16384
);

-- ============================================================================
-- TEST 3 — Marqueur de fin incorrect
-- Erreur attendue : PUBLIC_KEY_INVALID_PUBLIC_KEY_PEM
-- ============================================================================
RETURN fn::validation_public_key_pem(
    "-----BEGIN PUBLIC KEY-----\nQUJDRA==\n-----END PRIVATE KEY-----",
    "PUBLIC_KEY",
    16384
);
