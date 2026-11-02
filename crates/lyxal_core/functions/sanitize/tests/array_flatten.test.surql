-- lyxal-test: assertions
-- Tests de fn::sanitize_array_flatten (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: un niveau
RETURN fn::sanitize_array_flatten([[1, 2], [3, [4]]]) == [1, 2, 3, [4]];

-- test: entrée absente → NONE
RETURN fn::sanitize_array_flatten(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_flatten(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_flatten("a");
