-- lyxal-test: assertions
-- Tests de fn::sanitize_lowercase (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: minuscules Unicode
RETURN fn::sanitize_lowercase("ÉTÉ Lyxal") == "été lyxal";

-- test: entrée absente → NONE
RETURN fn::sanitize_lowercase(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_lowercase(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_lowercase(42);
