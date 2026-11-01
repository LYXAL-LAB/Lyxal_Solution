-- lyxal-test: assertions
-- Tests de fn::validation_integer (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur dans les bornes
RETURN fn::validation_integer(42, 1, 100)
    == { valid: true, value: 42, code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_integer(42, NONE, NONE)
    == { valid: true, value: 42, code: NONE, details: {} };

-- test: type exact conservé
RETURN type::of(fn::validation_integer(7, NONE, NONE).value) == "int";

-- test: borne minimale incluse
RETURN fn::validation_integer(1, 1, 100)
    == { valid: true, value: 1, code: NONE, details: {} };

-- test: trop petit
RETURN fn::validation_integer(0, 1, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1 } };

-- test: trop grand
RETURN fn::validation_integer(101, 1, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 100 } };

-- test: valeur absente
RETURN fn::validation_integer(NONE, 1, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_integer(NULL, 1, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type float refusé
RETURN fn::validation_integer(42.5f, 1, 100)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "float" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_integer(42, 100, 1);
