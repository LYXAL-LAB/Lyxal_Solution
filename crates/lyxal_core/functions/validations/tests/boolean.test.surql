-- lyxal-test: assertions
-- Tests de fn::validation_boolean (format : crates/lyxal_core/implementation_plan.md §5).

-- test: true accepté
RETURN fn::validation_boolean(true)
    == { valid: true, value: true, code: NONE, details: {} };

-- test: false accepté
RETURN fn::validation_boolean(false)
    == { valid: true, value: false, code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_boolean(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_boolean(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_boolean("true")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "bool", actual: "string" } };

-- test: type int refusé
RETURN fn::validation_boolean(1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "bool", actual: "int" } };
