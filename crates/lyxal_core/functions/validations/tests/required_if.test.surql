-- lyxal-test: assertions
-- Tests de fn::validation_required_if (format : crates/lyxal_core/implementation_plan.md §5).

-- test: obligatoire et présente
RETURN fn::validation_required_if("ACME", true, false)
    == { valid: true, value: "ACME", code: NONE, details: {} };

-- test: non obligatoire et absente
RETURN fn::validation_required_if(NONE, false, false)
    == { valid: true, value: NONE, code: NONE, details: {} };

-- test: obligatoire et absente
RETURN fn::validation_required_if(NONE, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: obligatoire et NULL refusée
RETURN fn::validation_required_if(NULL, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: obligatoire et NULL autorisée
RETURN fn::validation_required_if(NULL, true, true)
    == { valid: true, value: NULL, code: NONE, details: {} };
