-- lyxal-test: assertions
-- Tests de fn::validation_port (format : crates/lyxal_core/implementation_plan.md §5).

-- test: port dans les bornes
RETURN fn::validation_port(8080, 1024, 65535)
    == { valid: true, value: 8080, code: NONE, details: {} };

-- test: trop petit
RETURN fn::validation_port(80, 1024, 65535)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1024 } };

-- test: trop grand
RETURN fn::validation_port(70000, 0, 65535)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 65535 } };

-- test: valeur absente
RETURN fn::validation_port(NONE, 0, 65535)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_port(NULL, 0, 65535)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_port("8080", 0, 65535)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "string" } };

-- test: borne hors plage
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_port(80, 0, 70000);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_port(80, 100, 10);
