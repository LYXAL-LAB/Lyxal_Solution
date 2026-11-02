-- lyxal-test: assertions
-- Tests de fn::validation_integer_range (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: intervalle valide
RETURN fn::validation_integer_range(2, 10, false)
    == { valid: true, value: { min_value: 2, max_value: 10, span: 8 }, code: NONE, details: {} };

-- test: bornes égales autorisées
RETURN fn::validation_integer_range(5, 5, true)
    == { valid: true, value: { min_value: 5, max_value: 5, span: 0 }, code: NONE, details: {} };

-- test: bornes égales refusées
RETURN fn::validation_integer_range(5, 5, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_RANGE_ORDER", details: { min_value: 5, max_value: 5, allow_equal: false } };

-- test: bornes inversées
RETURN fn::validation_integer_range(10, 2, true).code == "CORE_VALIDATION_RANGE_ORDER";

-- test: borne basse absente
RETURN fn::validation_integer_range(NONE, 2, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "min" } };

-- test: borne haute NULL
RETURN fn::validation_integer_range(1, NULL, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "max" } };

-- test: borne haute non entière
RETURN fn::validation_integer_range(1, 2.5f, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "max", expected: "int", actual: "float" } };
