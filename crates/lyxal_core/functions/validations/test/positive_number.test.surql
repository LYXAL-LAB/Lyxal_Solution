-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/positive_number.test.surql
-- Fonction     : fn::validation_positive_number
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Entier positif
-- Résultat attendu : 42
-- ============================================================================
RETURN fn::validation_positive_number(42, "QUANTITY");

-- ============================================================================
-- TEST 2 — Decimal positif
-- Résultat attendu : 0.01dec
-- ============================================================================
RETURN fn::validation_positive_number(0.01dec, "AMOUNT");

-- ============================================================================
-- TEST 3 — Zéro refusé
-- Erreur attendue : QUANTITY_NOT_POSITIVE
-- ============================================================================
RETURN fn::validation_positive_number(0, "QUANTITY");

-- ============================================================================
-- TEST 4 — Nombre négatif refusé
-- Erreur attendue : QUANTITY_NOT_POSITIVE
-- ============================================================================
RETURN fn::validation_positive_number(-1, "QUANTITY");

-- ============================================================================
-- TEST 5 — Type invalide
-- Erreur attendue : QUANTITY_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_positive_number("42", "QUANTITY");
