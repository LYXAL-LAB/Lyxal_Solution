-- lyxal-test: assertions
-- Tests de fn::validation_latitude (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur dans les bornes
RETURN fn::validation_latitude(48.8566f)
    == { valid: true, value: 48.8566f, code: NONE, details: {} };

-- test: borne incluse
RETURN fn::validation_latitude(-90)
    == { valid: true, value: -90, code: NONE, details: {} };

-- test: trop petite
RETURN fn::validation_latitude(-90.5f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: -90 } };

-- test: trop grande
RETURN fn::validation_latitude(91)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 90 } };

-- test: valeur absente
RETURN fn::validation_latitude(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_latitude(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_latitude("48.8")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };
