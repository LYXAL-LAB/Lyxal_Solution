-- lyxal-test: assertions
-- Tests de fn::validation_date_string (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme nettoyée
RETURN fn::validation_date_string(" 2026-08-03 ")
    == { valid: true, value: "2026-08-03", code: NONE, details: {} };

-- test: date impossible
RETURN fn::validation_date_string("2026-02-30")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date_string" } };

-- test: format JJ/MM/AAAA
RETURN fn::validation_date_string("03/08/2026")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date_string" } };

-- test: chaîne blanche
RETURN fn::validation_date_string("  ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_date_string(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_date_string(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_date_string(1)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
