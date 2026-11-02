-- lyxal-test: assertions
-- Tests de fn::validation_surql_parameter (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_surql_parameter(" my_param ", false)
    == { valid: true, value: "my_param", code: NONE, details: {} };

-- test: nom réservé autorisé
RETURN fn::validation_surql_parameter("session", true)
    == { valid: true, value: "session", code: NONE, details: {} };

-- test: préfixe $ refusé
RETURN fn::validation_surql_parameter("$my_param", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_identifier" } };

-- test: nom réservé
RETURN fn::validation_surql_parameter("SESSION", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };

-- test: chaîne blanche
RETURN fn::validation_surql_parameter("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_surql_parameter(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_surql_parameter(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_surql_parameter(42, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
