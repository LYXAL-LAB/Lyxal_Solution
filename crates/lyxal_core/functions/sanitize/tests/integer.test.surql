-- lyxal-test: assertions
-- Tests de fn::sanitize_integer (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: espaces et signe
RETURN fn::sanitize_integer(" -1 234 ") == "-1234";

-- test: aucun chiffre
RETURN fn::sanitize_integer("abc") == "";

-- test: tiret seul
RETURN fn::sanitize_integer("-") == "";

-- test: entrée absente → NONE
RETURN fn::sanitize_integer(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_integer(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_integer(42);
