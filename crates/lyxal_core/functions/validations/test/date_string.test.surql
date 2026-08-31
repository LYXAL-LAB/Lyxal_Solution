-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/date_string.test.surql
-- Fonction     : fn::validation_date_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Date valide
-- Résultat attendu : "2026-08-03"
-- ============================================================================
RETURN fn::validation_date_string("2026-08-03", "DATE");

-- ============================================================================
-- TEST 2 — Année bissextile valide
-- Résultat attendu : "2024-02-29"
-- ============================================================================
RETURN fn::validation_date_string("2024-02-29", "DATE");

-- ============================================================================
-- TEST 3 — Date impossible
-- Erreur attendue : DATE_INVALID_DATE_STRING
-- ============================================================================
RETURN fn::validation_date_string("2026-02-30", "DATE");

-- ============================================================================
-- TEST 4 — Format français refusé
-- Erreur attendue : DATE_INVALID_DATE_STRING
-- ============================================================================
RETURN fn::validation_date_string("03/08/2026", "DATE");

-- ============================================================================
-- TEST 5 — Datetime complet refusé
-- Erreur attendue : DATE_INVALID_DATE_STRING
-- ============================================================================
RETURN fn::validation_date_string("2026-08-03T10:00:00Z", "DATE");
