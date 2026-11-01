-- lyxal-test: assertions
-- Tests de fn::validation_array_unique (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur acceptée
RETURN fn::validation_array_unique([1, 2, "1"])
    == { valid: true, value: [1, 2, "1"], code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_array_unique(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_unique(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_array_unique(1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "int" } };

-- test: doublon
RETURN fn::validation_array_unique([1, 2, 1])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_DUPLICATE", details: {} };

-- test: 1 et 1.0 sont des doublons
RETURN fn::validation_array_unique([1, 1.0f]).code == "CORE_VALIDATION_DUPLICATE";
