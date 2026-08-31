-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/negative_number.test.surql
-- Fonction     : fn::validation_negative_number
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Entier négatif
-- Résultat attendu : -42
-- ============================================================================
RETURN fn::validation_negative_number(-42, "BALANCE");

-- ============================================================================
-- TEST 2 — Float négatif
-- Résultat attendu : -0.5f
-- ============================================================================
RETURN fn::validation_negative_number(-0.5f, "DELTA");

-- ============================================================================
-- TEST 3 — Zéro refusé
-- Erreur attendue : BALANCE_NOT_NEGATIVE
-- ============================================================================
RETURN fn::validation_negative_number(0, "BALANCE");

-- ============================================================================
-- TEST 4 — Positif refusé
-- Erreur attendue : BALANCE_NOT_NEGATIVE
-- ============================================================================
RETURN fn::validation_negative_number(1, "BALANCE");
