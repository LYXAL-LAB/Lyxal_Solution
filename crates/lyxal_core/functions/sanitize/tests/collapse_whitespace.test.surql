-- lyxal-test: assertions
-- Tests de fn::sanitize_collapse_whitespace (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: espaces mélangés
RETURN fn::sanitize_collapse_whitespace("  a \t\n  b   c ") == "a b c";

-- test: entrée absente → NONE
RETURN fn::sanitize_collapse_whitespace(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_collapse_whitespace(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_collapse_whitespace(42);
