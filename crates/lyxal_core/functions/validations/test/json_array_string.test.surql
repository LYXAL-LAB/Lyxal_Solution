-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/json_array_string.test.surql
-- Fonction     : fn::validation_json_array_string
-- Version      : 1.0.0
--
-- Les tests produisant un THROW ou une erreur native doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================

-- TEST 1 — Tableau valide
RETURN fn::validation_json_array_string('[1,2,3]', "ITEMS", false, 1, 5);

-- TEST 2 — Objet racine refusé
-- Erreur attendue : ITEMS_JSON_ROOT_NOT_ARRAY
RETURN fn::validation_json_array_string('{"a":1}', "ITEMS", true, NONE, NONE);

-- TEST 3 — Trop long
-- Erreur attendue : ITEMS_TOO_LONG
RETURN fn::validation_json_array_string('[1,2,3]', "ITEMS", false, NONE, 2);
