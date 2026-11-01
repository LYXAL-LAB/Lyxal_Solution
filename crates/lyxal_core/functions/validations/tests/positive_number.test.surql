-- lyxal-test: assertions
-- Tests de fn::validation_positive_number (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur acceptée
RETURN fn::validation_positive_number(0.5dec)
    == { valid: true, value: 0.5dec, code: NONE, details: {} };

-- test: valeur refusée
RETURN fn::validation_positive_number(0)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0, exclusive: true } };

-- test: valeur absente
RETURN fn::validation_positive_number(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_positive_number(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_positive_number("1")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };
