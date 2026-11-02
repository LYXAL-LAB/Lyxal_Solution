-- lyxal-test: assertions
-- Tests de fn::sanitize_trim_left (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: espaces initiaux
RETURN fn::sanitize_trim_left("  a b  ") == "a b  ";

-- test: entrée absente → NONE
RETURN fn::sanitize_trim_left(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_trim_left(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_trim_left(42);
