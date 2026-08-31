-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array.test.surql
-- Fonction     : fn::validation_array
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tableau valide
-- Résultat attendu : [1, 2, 3]
-- ============================================================================
RETURN fn::validation_array([1, 2, 3], "ITEMS");

-- ============================================================================
-- TEST 2 — Tableau vide valide
-- Résultat attendu : []
-- ============================================================================
RETURN fn::validation_array([], "ITEMS");

-- ============================================================================
-- TEST 3 — Objet refusé
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_array({ a: 1 }, "ITEMS");

-- ============================================================================
-- TEST 4 — NONE
-- Erreur attendue : ITEMS_REQUIRED
-- ============================================================================
RETURN fn::validation_array(NONE, "ITEMS");
