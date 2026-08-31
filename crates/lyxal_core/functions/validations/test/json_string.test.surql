-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/json_string.test.surql
-- Fonction     : fn::validation_json_string
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Objet JSON valide
RETURN fn::validation_json_string('{"name":"Lyxal","enabled":true}', "JSON");

-- TEST 2 — Tableau JSON valide
RETURN fn::validation_json_string('[1,2,3]', "JSON");

-- TEST 3 — JSON malformé
-- Erreur attendue : erreur native encoding::json::decode()
RETURN fn::validation_json_string('{"name":"Lyxal"', "JSON");

-- TEST 4 — Type incorrect
-- Erreur attendue : JSON_INVALID_TYPE
RETURN fn::validation_json_string({ name: "Lyxal" }, "JSON");
