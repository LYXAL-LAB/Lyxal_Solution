-- lyxal-test: assertions
-- Tests de fn::validation_longitude (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur dans les bornes
RETURN fn::validation_longitude(48.8566f)
    == { valid: true, value: 48.8566f, code: NONE, details: {} };

-- test: borne incluse
RETURN fn::validation_longitude(-180)
    == { valid: true, value: -180, code: NONE, details: {} };

-- test: trop petite
RETURN fn::validation_longitude(-180.5f)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: -180 } };

-- test: trop grande
RETURN fn::validation_longitude(181)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 180 } };

-- test: valeur absente
RETURN fn::validation_longitude(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_longitude(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_longitude("48.8")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "number", actual: "string" } };
