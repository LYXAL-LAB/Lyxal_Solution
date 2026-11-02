-- lyxal-test: assertions
-- Tests de fn::validation_negative_number (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur acceptée
RETURN fn::validation_negative_number(-3)
    == { valid: true, value: -3, code: NONE, details: {} };

-- test: valeur refusée
RETURN fn::validation_negative_number(0)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 0, exclusive: true } };

-- test: valeur absente
RETURN fn::validation_negative_number(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_negative_number(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_negative_number("1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };
