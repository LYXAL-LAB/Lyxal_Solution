-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/content_type.test.surql
-- Fonction     : fn::validation_content_type
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — JSON avec charset
RETURN fn::validation_content_type("Application/JSON; Charset=UTF-8", "CONTENT_TYPE", ["application/json"]);

-- TEST 2 — Type interdit
-- Erreur attendue : CONTENT_TYPE_MEDIA_TYPE_NOT_ALLOWED
RETURN fn::validation_content_type("text/plain", "CONTENT_TYPE", ["application/json"]);

-- TEST 3 — Forme invalide
-- Erreur attendue : CONTENT_TYPE_INVALID_CONTENT_TYPE
RETURN fn::validation_content_type("application", "CONTENT_TYPE", NONE);
