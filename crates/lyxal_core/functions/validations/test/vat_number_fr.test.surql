-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/vat_number_fr.test.surql
-- Fonction     : fn::validation_vat_number_fr
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — TVA valide
RETURN fn::validation_vat_number_fr("FR44 732829320", "VAT_NUMBER", true);

-- TEST 2 — Pays incorrect
-- Erreur attendue : VAT_NUMBER_INVALID_VAT_NUMBER
RETURN fn::validation_vat_number_fr("DE44732829320", "VAT_NUMBER", true);

-- TEST 3 — Clé incorrecte
-- Erreur attendue : VAT_NUMBER_INVALID_VAT_KEY
RETURN fn::validation_vat_number_fr("FR45 732829320", "VAT_NUMBER", true);

-- TEST 4 — Clé alphanumérique
RETURN fn::validation_vat_number_fr("FRXX732829320", "VAT_NUMBER", true);
