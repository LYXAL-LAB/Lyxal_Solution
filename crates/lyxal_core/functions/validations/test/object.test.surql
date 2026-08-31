-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object.test.surql
-- Fonction     : fn::validation_object
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet valide
-- Résultat attendu : { name: "Lyxal" }
-- ============================================================================
RETURN fn::validation_object({ name: "Lyxal" }, "METADATA");

-- ============================================================================
-- TEST 2 — Objet vide valide
-- Résultat attendu : {}
-- ============================================================================
RETURN fn::validation_object({}, "METADATA");

-- ============================================================================
-- TEST 3 — Tableau refusé
-- Erreur attendue : METADATA_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_object([], "METADATA");
