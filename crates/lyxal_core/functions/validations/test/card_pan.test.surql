-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/card_pan.test.surql
-- Fonction     : fn::validation_card_pan
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Visa
RETURN fn::validation_card_pan("4111111111111111", "CARD_NUMBER", ["visa"]);

-- TEST 2 — Mastercard
RETURN fn::validation_card_pan("5555555555554444", "CARD_NUMBER", ["mastercard"]);

-- TEST 3 — Amex
RETURN fn::validation_card_pan("378282246310005", "CARD_NUMBER", ["amex"]);

-- TEST 4 — Réseau interdit
-- Erreur attendue : CARD_NUMBER_NETWORK_NOT_ALLOWED
RETURN fn::validation_card_pan("4111111111111111", "CARD_NUMBER", ["mastercard"]);
