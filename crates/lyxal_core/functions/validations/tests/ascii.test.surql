-- lyxal-test: assertions
-- Tests de fn::validation_ascii (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme nettoyée
RETURN fn::validation_ascii(" " + "Hello-123" + " ", true, false)
    == { valid: true, value: "Hello-123", code: NONE, details: {} };

-- test: valeur non conforme
RETURN fn::validation_ascii("Été", true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ascii" } };

-- test: vide autorisée
RETURN fn::validation_ascii("  ", true, true)
    == { valid: true, value: "", code: NONE, details: {} };

-- test: vide refusée
RETURN fn::validation_ascii("  ", true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_ascii(NONE, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ascii(NULL, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ascii(1, true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
