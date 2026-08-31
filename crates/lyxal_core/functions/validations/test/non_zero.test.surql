-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/non_zero.test.surql
-- Fonction     : fn::validation_non_zero
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Positif non nul
-- Résultat attendu : 1
-- ============================================================================
RETURN fn::validation_non_zero(1, "DIVISOR");

-- ============================================================================
-- TEST 2 — Négatif non nul
-- Résultat attendu : -1
-- ============================================================================
RETURN fn::validation_non_zero(-1, "DELTA");

-- ============================================================================
-- TEST 3 — Zéro entier refusé
-- Erreur attendue : DIVISOR_ZERO_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_non_zero(0, "DIVISOR");

-- ============================================================================
-- TEST 4 — Zéro decimal refusé
-- Erreur attendue : DIVISOR_ZERO_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_non_zero(0dec, "DIVISOR");
