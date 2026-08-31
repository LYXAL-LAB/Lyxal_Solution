-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_unique.test.surql
-- Fonction     : fn::validation_array_unique
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Valeurs uniques
-- Résultat attendu : [1, 2, 3]
-- ============================================================================
RETURN fn::validation_array_unique([1, 2, 3], "ITEMS");

-- ============================================================================
-- TEST 2 — Doublon entier
-- Erreur attendue : ITEMS_DUPLICATES_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_array_unique([1, 2, 1], "ITEMS");

-- ============================================================================
-- TEST 3 — Doublon chaîne
-- Erreur attendue : TAGS_DUPLICATES_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_array_unique(["rust", "surql", "rust"], "TAGS");

-- ============================================================================
-- TEST 4 — Tableau vide valide
-- Résultat attendu : []
-- ============================================================================
RETURN fn::validation_array_unique([], "ITEMS");
