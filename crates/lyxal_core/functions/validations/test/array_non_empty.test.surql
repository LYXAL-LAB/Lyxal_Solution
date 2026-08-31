-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_non_empty.test.surql
-- Fonction     : fn::validation_array_non_empty
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tableau non vide
-- Résultat attendu : ["admin"]
-- ============================================================================
RETURN fn::validation_array_non_empty(["admin"], "ROLES");

-- ============================================================================
-- TEST 2 — Tableau vide
-- Erreur attendue : ROLES_EMPTY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_array_non_empty([], "ROLES");

-- ============================================================================
-- TEST 3 — Chaîne refusée
-- Erreur attendue : ROLES_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_array_non_empty("admin", "ROLES");
