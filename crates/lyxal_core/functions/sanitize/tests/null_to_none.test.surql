-- lyxal-test: assertions
-- Tests de fn::sanitize_null_to_none (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: NULL remplacé
RETURN fn::sanitize_null_to_none({ a: NULL, b: 1 }) == { a: NONE, b: 1 };

-- test: entrée absente → NONE
RETURN fn::sanitize_null_to_none(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_null_to_none(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_null_to_none([1]);
