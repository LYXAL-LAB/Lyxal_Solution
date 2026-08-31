-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/first_name.test.surql
-- Fonction     : fn::validation_first_name
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Prénom simple
-- Résultat attendu : "Yaniss"
-- ============================================================================
RETURN fn::validation_first_name("Yaniss", "FIRST_NAME", 1, 100);

-- ============================================================================
-- TEST 2 — Prénom composé
-- Résultat attendu : "Jean-Pierre"
-- ============================================================================
RETURN fn::validation_first_name("Jean-Pierre", "FIRST_NAME", 1, 100);

-- ============================================================================
-- TEST 3 — Apostrophe
-- Résultat attendu : "D'Angelo"
-- ============================================================================
RETURN fn::validation_first_name("D'Angelo", "FIRST_NAME", 1, 100);

-- ============================================================================
-- TEST 4 — Chiffres interdits
-- Erreur attendue : FIRST_NAME_INVALID_FIRST_NAME
-- ============================================================================
RETURN fn::validation_first_name("Yaniss2", "FIRST_NAME", 1, 100);
