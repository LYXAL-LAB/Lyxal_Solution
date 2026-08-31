-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_length.test.surql
-- Fonction     : fn::validation_array_length
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Longueur valide
-- Résultat attendu : [1, 2, 3]
-- ============================================================================
RETURN fn::validation_array_length([1, 2, 3], "ITEMS", 1, 5);

-- ============================================================================
-- TEST 2 — Limite minimale
-- Résultat attendu : [1]
-- ============================================================================
RETURN fn::validation_array_length([1], "ITEMS", 1, 5);

-- ============================================================================
-- TEST 3 — Trop court
-- Erreur attendue : ITEMS_TOO_SHORT
-- ============================================================================
RETURN fn::validation_array_length([], "ITEMS", 1, 5);

-- ============================================================================
-- TEST 4 — Trop long
-- Erreur attendue : ITEMS_TOO_LONG
-- ============================================================================
RETURN fn::validation_array_length([1, 2, 3], "ITEMS", NONE, 2);

-- ============================================================================
-- TEST 5 — Plage incohérente
-- Erreur attendue : VALIDATION_INVALID_ARRAY_LENGTH_RANGE
-- ============================================================================
RETURN fn::validation_array_length([1], "ITEMS", 5, 1);
