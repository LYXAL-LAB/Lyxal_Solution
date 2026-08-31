-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/http_method.test.surql
-- Fonction     : fn::validation_http_method
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — POST normalisé
RETURN fn::validation_http_method("post", "METHOD", NONE);

-- TEST 2 — DELETE interdit
-- Erreur attendue : METHOD_HTTP_METHOD_NOT_ALLOWED
RETURN fn::validation_http_method("DELETE", "METHOD", ["GET", "POST"]);

-- TEST 3 — Forme invalide
-- Erreur attendue : METHOD_INVALID_HTTP_METHOD
RETURN fn::validation_http_method("POST /", "METHOD", NONE);
