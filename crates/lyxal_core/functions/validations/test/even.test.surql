-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/even.test.surql
-- Fonction     : fn::validation_even
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Pair positif
-- Résultat attendu : 42
-- ============================================================================
RETURN fn::validation_even(42, "VALUE");

-- ============================================================================
-- TEST 2 — Zéro est pair
-- Résultat attendu : 0
-- ============================================================================
RETURN fn::validation_even(0, "VALUE");

-- ============================================================================
-- TEST 3 — Pair négatif
-- Résultat attendu : -42
-- ============================================================================
RETURN fn::validation_even(-42, "VALUE");

-- ============================================================================
-- TEST 4 — Impair refusé
-- Erreur attendue : VALUE_NOT_EVEN
-- ============================================================================
RETURN fn::validation_even(41, "VALUE");
