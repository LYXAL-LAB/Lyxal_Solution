-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/nonce.test.surql
-- Fonction     : fn::validation_nonce
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nonce valide
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_nonce(
    "D5j2aP9x_kLm-2026",
    "NONCE",
    16,
    256
);

-- ============================================================================
-- TEST 2 — Trop court
-- Erreur attendue : NONCE_TOO_SHORT
-- ============================================================================
RETURN fn::validation_nonce(
    "abc",
    "NONCE",
    16,
    256
);

-- ============================================================================
-- TEST 3 — Espace interdit
-- Erreur attendue : NONCE_INVALID_NONCE
-- ============================================================================
RETURN fn::validation_nonce(
    "D5j2aP9x kLm 2026",
    "NONCE",
    16,
    256
);
