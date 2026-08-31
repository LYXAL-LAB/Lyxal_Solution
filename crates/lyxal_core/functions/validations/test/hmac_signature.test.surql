-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/hmac_signature.test.surql
-- Fonction     : fn::validation_hmac_signature
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Hex valide
RETURN fn::validation_hmac_signature("AABBCCDDEEFF", "SIGNATURE", "hex", 12);

-- TEST 2 — Base64 valide
RETURN fn::validation_hmac_signature("YWJjZA==", "SIGNATURE", "base64", NONE);

-- TEST 3 — Hex invalide
-- Erreur attendue : SIGNATURE_INVALID_HMAC_SIGNATURE
RETURN fn::validation_hmac_signature("AABBGG", "SIGNATURE", "hex", NONE);
