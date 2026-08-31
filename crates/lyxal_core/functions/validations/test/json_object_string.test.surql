-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/json_object_string.test.surql
-- Fonction     : fn::validation_json_object_string
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Objet valide
RETURN fn::validation_json_object_string('{"name":"Lyxal"}', "BODY", false);

-- TEST 2 — Objet vide interdit
-- Erreur attendue : BODY_EMPTY_OBJECT_NOT_ALLOWED
RETURN fn::validation_json_object_string('{}', "BODY", false);

-- TEST 3 — Tableau racine refusé
-- Erreur attendue : BODY_JSON_ROOT_NOT_OBJECT
RETURN fn::validation_json_object_string('[1,2]', "BODY", true);
