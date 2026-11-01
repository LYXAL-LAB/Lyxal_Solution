-- lyxal-test: assertions
-- Tests de fn::validation_record_exists (format : crates/lyxal_core/implementation_plan.md §5).

-- test: enregistrement existant
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_record_exists(lyxal_test_ref:one).valid; };

-- test: enregistrement inexistant
RETURN fn::validation_record_exists(lyxal_test_absent:x)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_FOUND", details: {} };

-- test: valeur absente
RETURN fn::validation_record_exists(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_record_exists(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_record_exists("a:b")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "record", actual: "string" } };
