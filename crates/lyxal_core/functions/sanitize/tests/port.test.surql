-- lyxal-test: assertions
-- Tests de fn::sanitize_port (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: chiffres seuls
RETURN fn::sanitize_port(" :8080 ") == "8080";

-- test: entrée absente → NONE
RETURN fn::sanitize_port(NONE) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_port(NULL);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_port(42);
