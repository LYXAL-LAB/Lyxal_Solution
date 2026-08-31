-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/time_of_day.test.surql
-- Fonction     : fn::validation_time_of_day
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Minuit
-- Résultat attendu : 0
-- ============================================================================
RETURN fn::validation_time_of_day(0, "START_MINUTE");

-- ============================================================================
-- TEST 2 — 09:30
-- Résultat attendu : 570
-- ============================================================================
RETURN fn::validation_time_of_day(570, "START_MINUTE");

-- ============================================================================
-- TEST 3 — 23:59
-- Résultat attendu : 1439
-- ============================================================================
RETURN fn::validation_time_of_day(1439, "START_MINUTE");

-- ============================================================================
-- TEST 4 — Valeur négative
-- Erreur attendue : START_MINUTE_OUT_OF_DAY_RANGE
-- ============================================================================
RETURN fn::validation_time_of_day(-1, "START_MINUTE");

-- ============================================================================
-- TEST 5 — 24:00 hors plage
-- Erreur attendue : START_MINUTE_OUT_OF_DAY_RANGE
-- ============================================================================
RETURN fn::validation_time_of_day(1440, "START_MINUTE");
