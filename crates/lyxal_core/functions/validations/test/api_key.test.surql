-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/api_key.test.surql
-- Fonction     : fn::validation_api_key
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Clé valide
RETURN fn::validation_api_key("lyxal_live_abcd1234", "API_KEY", ["lyxal_live_", "lyxal_test_"], 16, 128);

-- TEST 2 — Préfixe interdit
-- Erreur attendue : API_KEY_API_KEY_PREFIX_NOT_ALLOWED
RETURN fn::validation_api_key("other_abcd123456", "API_KEY", ["lyxal_live_"], 16, 128);

-- TEST 3 — Espace interdit
-- Erreur attendue : API_KEY_INVALID_API_KEY
RETURN fn::validation_api_key("lyxal_live_abcd 1234", "API_KEY", NONE, 8, 128);
