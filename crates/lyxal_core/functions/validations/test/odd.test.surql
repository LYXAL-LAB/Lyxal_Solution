-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/odd.test.surql
-- Fonction     : fn::validation_odd
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Impair positif
-- Résultat attendu : 41
-- ============================================================================
RETURN fn::validation_odd(41, "VALUE");

-- ============================================================================
-- TEST 2 — Impair négatif
-- Résultat attendu : -41
-- ============================================================================
RETURN fn::validation_odd(-41, "VALUE");

-- ============================================================================
-- TEST 3 — Pair refusé
-- Erreur attendue : VALUE_NOT_ODD
-- ============================================================================
RETURN fn::validation_odd(42, "VALUE");

-- ============================================================================
-- TEST 4 — Zéro refusé
-- Erreur attendue : VALUE_NOT_ODD
-- ============================================================================
RETURN fn::validation_odd(0, "VALUE");
