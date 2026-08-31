-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/bearer_token.test.surql
-- Fonction     : fn::validation_bearer_token
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Bearer valide
RETURN fn::validation_bearer_token("Bearer abc.def.ghi", "AUTHORIZATION", 8, 4096);

-- TEST 2 — Schéma absent
-- Erreur attendue : AUTHORIZATION_INVALID_BEARER_FORMAT
RETURN fn::validation_bearer_token("abc.def.ghi", "AUTHORIZATION", 8, 4096);

-- TEST 3 — Trop court
-- Erreur attendue : AUTHORIZATION_TOKEN_TOO_SHORT
RETURN fn::validation_bearer_token("Bearer abc", "AUTHORIZATION", 8, 4096);
