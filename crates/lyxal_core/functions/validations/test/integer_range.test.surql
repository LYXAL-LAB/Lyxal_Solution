-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/integer_range.test.surql
-- Fonction     : fn::validation_integer_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- ============================================================================
-- TEST 1 — Plage valide
-- Résultat attendu : { min_value: 1, max_value: 10, span: 9 }
-- ============================================================================
RETURN fn::validation_integer_range(1, 10, "RANGE", false);

-- ============================================================================
-- TEST 2 — Bornes égales autorisées
-- Résultat attendu : span 0
-- ============================================================================
RETURN fn::validation_integer_range(5, 5, "RANGE", true);

-- ============================================================================
-- TEST 3 — Bornes inversées
-- Erreur attendue : RANGE_INVALID_ORDER
-- ============================================================================
RETURN fn::validation_integer_range(10, 1, "RANGE", false);

-- ============================================================================
-- TEST 4 — Bornes égales interdites
-- Erreur attendue : RANGE_EQUAL_BOUNDS_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_integer_range(5, 5, "RANGE", false);

-- ============================================================================
-- TEST 5 — Minimum de type incorrect
-- Erreur attendue : RANGE_MIN_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_integer_range(1dec, 10, "RANGE", false);
