-- lyxal-test: assertions
-- Tests de fn::validation_optional_string (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chaîne nettoyée
RETURN fn::validation_optional_string("  note ", NONE, 10)
    == { valid: true, value: "note", code: NONE, details: {} };

-- test: absente
RETURN fn::validation_optional_string(NONE, NONE, 10)
    == { valid: true, value: NONE, code: NONE, details: {} };

-- test: blanche devient NONE
RETURN fn::validation_optional_string("   ", 3, 10)
    == { valid: true, value: NONE, code: NONE, details: {} };

-- test: trop courte
RETURN fn::validation_optional_string("ab", 3, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 3, length: 2 } };

-- test: trop longue
RETURN fn::validation_optional_string("abcdef", NONE, 5)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 5, length: 6 } };

-- test: NULL refusé
RETURN fn::validation_optional_string(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type bool refusé
RETURN fn::validation_optional_string(true, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "bool" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_optional_string("a", 10, 2);
