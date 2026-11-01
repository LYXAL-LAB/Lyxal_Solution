-- lyxal-test: assertions
-- Tests de fn::validation_birthdate (format : crates/lyxal_core/implementation_plan.md §5).

-- test: date passée
RETURN fn::validation_birthdate(d"1990-06-15T00:00:00Z", false)
    == { valid: true, value: d"1990-06-15T00:00:00Z", code: NONE, details: {} };

-- test: aujourd'hui autorisé
RETURN fn::validation_birthdate(time::floor(time::now(), 1d), true).valid;

-- test: aujourd'hui refusé
RETURN fn::validation_birthdate(time::floor(time::now(), 1d), false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: time::floor(time::now(), 1d), exclusive: true } };

-- test: date future
RETURN fn::validation_birthdate(d"2999-01-01T00:00:00Z", true).code == "CORE_VALIDATION_TOO_LARGE";

-- test: date avec heure
RETURN fn::validation_birthdate(d"1990-06-15T08:00:00Z", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date" } };

-- test: valeur absente
RETURN fn::validation_birthdate(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_birthdate(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_birthdate("1990-06-15", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: "string" } };
