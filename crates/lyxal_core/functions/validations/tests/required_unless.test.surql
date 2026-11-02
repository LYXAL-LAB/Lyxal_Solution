-- lyxal-test: assertions
-- Tests de fn::validation_required_unless (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: obligatoire et présente
RETURN fn::validation_required_unless("ACME", false, false)
    == { valid: true, value: "ACME", code: NONE, details: {} };

-- test: non obligatoire et absente
RETURN fn::validation_required_unless(NONE, true, false)
    == { valid: true, value: NONE, code: NONE, details: {} };

-- test: obligatoire et absente
RETURN fn::validation_required_unless(NONE, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: obligatoire et NULL refusée
RETURN fn::validation_required_unless(NULL, false, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: obligatoire et NULL autorisée
RETURN fn::validation_required_unless(NULL, false, true)
    == { valid: true, value: NULL, code: NONE, details: {} };
