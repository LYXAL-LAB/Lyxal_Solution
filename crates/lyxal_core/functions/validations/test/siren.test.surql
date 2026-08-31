-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/siren.test.surql
-- Fonction     : fn::validation_siren
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — SIREN valide
RETURN fn::validation_siren("732 829 320", "SIREN");

-- TEST 2 — Trop court
-- Erreur attendue : SIREN_TOO_SHORT
RETURN fn::validation_siren("73282932", "SIREN");

-- TEST 3 — Checksum invalide
-- Erreur attendue : SIREN_INVALID_LUHN_CHECKSUM
RETURN fn::validation_siren("732829321", "SIREN");
