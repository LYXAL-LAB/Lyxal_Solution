-- lyxal-test: assertions
-- Tests de fn::sanitize_array_sort (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: croissant
RETURN fn::sanitize_array_sort([3, 1, 2], "asc") == [1, 2, 3];

-- test: décroissant
RETURN fn::sanitize_array_sort([3, 1, 2], " DESC ") == [3, 2, 1];

-- test: sens inconnu
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::sanitize_array_sort([1], "up");

-- test: entrée absente → NONE
RETURN fn::sanitize_array_sort(NONE, "asc") == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_sort(NULL, "asc");

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_sort("a", "asc");
