-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/rib_fr.test.surql
-- Fonction     : fn::validation_rib_fr
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — RIB numérique
RETURN fn::validation_rib_fr("30006", "00001", "12345678901", "89", "RIB");

-- TEST 2 — Compte alphanumérique
RETURN fn::validation_rib_fr("30006", "00001", "A2345678901", "89", "RIB");

-- TEST 3 — Code banque invalide
-- Erreur attendue : RIB_BANK_CODE_INVALID
RETURN fn::validation_rib_fr("3006", "00001", "12345678901", "89", "RIB");

-- TEST 4 — Clé invalide
-- Erreur attendue : RIB_RIB_KEY_INVALID
RETURN fn::validation_rib_fr("30006", "00001", "12345678901", "089", "RIB");
