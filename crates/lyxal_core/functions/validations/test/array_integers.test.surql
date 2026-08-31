-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_integers.test.surql
-- Fonction     : fn::validation_array_integers
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Entiers valides
-- Résultat attendu : [1, 2, 3]
-- ============================================================================
RETURN fn::validation_array_integers(
    [1, 2, 3], "VALUES", 0, 10
);

-- ============================================================================
-- TEST 2 — Float refusé
-- Erreur attendue : VALUES_INVALID_ITEM_TYPE
-- ============================================================================
RETURN fn::validation_array_integers(
    [1, 2f], "VALUES", 0, 10
);

-- ============================================================================
-- TEST 3 — Valeur trop petite
-- Erreur attendue : VALUES_ITEM_TOO_SMALL
-- ============================================================================
RETURN fn::validation_array_integers(
    [-1, 2], "VALUES", 0, 10
);

-- ============================================================================
-- TEST 4 — Valeur trop grande
-- Erreur attendue : VALUES_ITEM_TOO_LARGE
-- ============================================================================
RETURN fn::validation_array_integers(
    [1, 11], "VALUES", 0, 10
);
