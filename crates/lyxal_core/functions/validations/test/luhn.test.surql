-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/luhn.test.surql
-- Fonction     : fn::validation_luhn
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Numéro Luhn valide
RETURN fn::validation_luhn("79927398713", "NUMBER", 1, 32);

-- TEST 2 — Visa de test
RETURN fn::validation_luhn("4111 1111 1111 1111", "PAN", 12, 19);

-- TEST 3 — Checksum invalide
-- Erreur attendue : NUMBER_INVALID_LUHN_CHECKSUM
RETURN fn::validation_luhn("79927398714", "NUMBER", 1, 32);

-- TEST 4 — Caractère invalide
-- Erreur attendue : NUMBER_INVALID_NUMERIC_VALUE
RETURN fn::validation_luhn("79927A98713", "NUMBER", 1, 32);
