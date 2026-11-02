-- lyxal-test: assertions
-- Tests de fn::sanitize_array_strings (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: chaînes nettoyées
RETURN fn::sanitize_array_strings([" A ", 1, "b", NULL], true, true) == ["a", "b"];

-- test: sans transformation
RETURN fn::sanitize_array_strings([" A ", 2], false, false) == [" A "];

-- test: entrée absente → NONE
RETURN fn::sanitize_array_strings(NONE, true, true) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_strings(NULL, true, true);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_strings("a", true, true);
