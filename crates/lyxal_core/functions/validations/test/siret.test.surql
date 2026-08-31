-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/siret.test.surql
-- Fonction     : fn::validation_siret
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — SIRET valide
RETURN fn::validation_siret("732 829 320 00074", "SIRET");

-- TEST 2 — Trop court
-- Erreur attendue : SIRET_TOO_SHORT
RETURN fn::validation_siret("7328293200007", "SIRET");

-- TEST 3 — Checksum invalide
-- Erreur attendue : SIRET_INVALID_LUHN_CHECKSUM
RETURN fn::validation_siret("73282932000075", "SIRET");
