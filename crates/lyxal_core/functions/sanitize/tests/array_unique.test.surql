-- lyxal-test: assertions
-- Tests de fn::sanitize_array_unique (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: doublons retirés
RETURN fn::sanitize_array_unique([1, 2, 1, "1", 2]) == [1, 2, "1"];

-- test: entrée absente → NONE
RETURN fn::sanitize_array_unique(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_unique(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_unique("a");
