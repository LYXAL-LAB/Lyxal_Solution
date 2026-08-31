-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/iban.test.surql
-- Fonction     : fn::validation_iban
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — IBAN français
RETURN fn::validation_iban("FR76 3000 6000 0112 3456 7890 189", "IBAN", ["FR"]);

-- TEST 2 — IBAN belge
RETURN fn::validation_iban("BE68 5390 0754 7034", "IBAN", ["BE", "FR"]);

-- TEST 3 — Longueur française incorrecte
-- Erreur attendue : IBAN_INVALID_IBAN_LENGTH
RETURN fn::validation_iban("FR7630006000011234567890", "IBAN", NONE);

-- TEST 4 — Pays interdit
-- Erreur attendue : IBAN_IBAN_COUNTRY_NOT_ALLOWED
RETURN fn::validation_iban("DE89370400440532013000", "IBAN", ["FR"]);
