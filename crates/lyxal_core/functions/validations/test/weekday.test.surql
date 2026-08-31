-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/weekday.test.surql
-- Fonction     : fn::validation_weekday
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Lundi valide
-- Résultat attendu : 1
-- ============================================================================
RETURN fn::validation_weekday(1, "WEEKDAY", NONE);

-- ============================================================================
-- TEST 2 — Dimanche valide
-- Résultat attendu : 7
-- ============================================================================
RETURN fn::validation_weekday(7, "WEEKDAY", NONE);

-- ============================================================================
-- TEST 3 — Jour ouvré autorisé
-- Résultat attendu : 5
-- ============================================================================
RETURN fn::validation_weekday(5, "WEEKDAY", [1, 2, 3, 4, 5]);

-- ============================================================================
-- TEST 4 — Week-end interdit
-- Erreur attendue : WEEKDAY_WEEKDAY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_weekday(6, "WEEKDAY", [1, 2, 3, 4, 5]);

-- ============================================================================
-- TEST 5 — Numéro invalide
-- Erreur attendue : WEEKDAY_INVALID_WEEKDAY
-- ============================================================================
RETURN fn::validation_weekday(8, "WEEKDAY", NONE);
