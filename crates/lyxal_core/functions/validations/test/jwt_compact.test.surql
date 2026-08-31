-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/jwt_compact.test.surql
-- Fonction     : fn::validation_jwt_compact
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Forme valide
RETURN fn::validation_jwt_compact("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMifQ.signature", "JWT", 8192);

-- TEST 2 — Deux segments
-- Erreur attendue : JWT_INVALID_JWT_FORMAT
RETURN fn::validation_jwt_compact("header.payload", "JWT", 8192);

-- TEST 3 — Segment vide
-- Erreur attendue : JWT_INVALID_JWT_FORMAT
RETURN fn::validation_jwt_compact("header..signature", "JWT", 8192);
