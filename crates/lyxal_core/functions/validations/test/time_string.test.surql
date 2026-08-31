-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/time_string.test.surql
-- Fonction     : fn::validation_time_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Heure sans secondes valide
-- Résultat attendu : "09:30"
-- ============================================================================
RETURN fn::validation_time_string("09:30", "TIME", false);

-- ============================================================================
-- TEST 2 — Heure avec secondes valide
-- Résultat attendu : "23:59:59"
-- ============================================================================
RETURN fn::validation_time_string("23:59:59", "TIME", true);

-- ============================================================================
-- TEST 3 — Heure 24 interdite
-- Erreur attendue : TIME_INVALID_TIME_STRING
-- ============================================================================
RETURN fn::validation_time_string("24:00", "TIME", false);

-- ============================================================================
-- TEST 4 — Secondes manquantes
-- Erreur attendue : TIME_INVALID_TIME_STRING
-- ============================================================================
RETURN fn::validation_time_string("09:30", "TIME", true);

-- ============================================================================
-- TEST 5 — Secondes présentes alors qu'elles ne sont pas attendues
-- Erreur attendue : TIME_INVALID_TIME_STRING
-- ============================================================================
RETURN fn::validation_time_string("09:30:00", "TIME", false);
