-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/non_negative_number.test.surql
-- Fonction     : fn::validation_non_negative_number
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Zéro accepté
-- Résultat attendu : 0
-- ============================================================================
RETURN fn::validation_non_negative_number(0, "AMOUNT");

-- ============================================================================
-- TEST 2 — Positif accepté
-- Résultat attendu : 25.5dec
-- ============================================================================
RETURN fn::validation_non_negative_number(25.5dec, "AMOUNT");

-- ============================================================================
-- TEST 3 — Négatif refusé
-- Erreur attendue : AMOUNT_NEGATIVE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_non_negative_number(-0.01dec, "AMOUNT");
