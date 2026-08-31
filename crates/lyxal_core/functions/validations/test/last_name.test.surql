-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/last_name.test.surql
-- Fonction     : fn::validation_last_name
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom simple
-- Résultat attendu : "Dubreucq"
-- ============================================================================
RETURN fn::validation_last_name("Dubreucq", "LAST_NAME", 1, 100);

-- ============================================================================
-- TEST 2 — Nom composé
-- Résultat attendu : "Le Gall"
-- ============================================================================
RETURN fn::validation_last_name("Le Gall", "LAST_NAME", 1, 100);

-- ============================================================================
-- TEST 3 — Apostrophe
-- Résultat attendu : "O'Connor"
-- ============================================================================
RETURN fn::validation_last_name("O'Connor", "LAST_NAME", 1, 100);

-- ============================================================================
-- TEST 4 — Slash interdit
-- Erreur attendue : LAST_NAME_INVALID_LAST_NAME
-- ============================================================================
RETURN fn::validation_last_name("Le/Gall", "LAST_NAME", 1, 100);
