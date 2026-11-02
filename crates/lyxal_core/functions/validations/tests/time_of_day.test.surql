-- lyxal-test: assertions
-- Tests de fn::validation_time_of_day (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: minuit
RETURN fn::validation_time_of_day(0)
    == { valid: true, value: 0, code: NONE, details: {} };

-- test: 23 h 59
RETURN fn::validation_time_of_day(1439)
    == { valid: true, value: 1439, code: NONE, details: {} };

-- test: négatif
RETURN fn::validation_time_of_day(-1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 0 } };

-- test: hors journée
RETURN fn::validation_time_of_day(1440)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 1439 } };

-- test: valeur absente
RETURN fn::validation_time_of_day(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_time_of_day(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_time_of_day("09:00")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "string" } };
