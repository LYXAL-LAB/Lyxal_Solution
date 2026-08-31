-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/multiple_of.test.surql
-- Fonction     : fn::validation_multiple_of
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Multiple valide
-- Résultat attendu : 20
-- ============================================================================
RETURN fn::validation_multiple_of(20, "QUANTITY", 5);

-- ============================================================================
-- TEST 2 — Multiple négatif valide
-- Résultat attendu : -20
-- ============================================================================
RETURN fn::validation_multiple_of(-20, "QUANTITY", 5);

-- ============================================================================
-- TEST 3 — Non multiple
-- Erreur attendue : QUANTITY_NOT_MULTIPLE
-- ============================================================================
RETURN fn::validation_multiple_of(22, "QUANTITY", 5);

-- ============================================================================
-- TEST 4 — Diviseur nul
-- Erreur attendue : VALIDATION_ZERO_DIVISOR
-- ============================================================================
RETURN fn::validation_multiple_of(20, "QUANTITY", 0);

-- ============================================================================
-- TEST 5 — Decimal refusé
-- Erreur attendue : QUANTITY_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_multiple_of(20dec, "QUANTITY", 5);
