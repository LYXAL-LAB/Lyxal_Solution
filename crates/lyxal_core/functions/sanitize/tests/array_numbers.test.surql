-- lyxal-test: assertions
-- Tests de fn::sanitize_array_numbers (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: nombres seuls
RETURN fn::sanitize_array_numbers([1, "2", 3.5f, NULL, 4dec]) == [1, 3.5f, 4dec];

-- test: entrée absente → NONE
RETURN fn::sanitize_array_numbers(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_numbers(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_numbers("a");
