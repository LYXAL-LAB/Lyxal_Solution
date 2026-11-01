-- lyxal-test: assertions
-- Tests de fn::validation_display_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_display_name(" Jean_Dupont.42 ", 2, 30, false)
    == { valid: true, value: "Jean_Dupont.42", code: NONE, details: {} };

-- test: emoji autorisé
RETURN fn::validation_display_name("Jean 🚀", 2, 30, true)
    == { valid: true, value: "Jean 🚀", code: NONE, details: {} };

-- test: emoji refusé
RETURN fn::validation_display_name("Jean 🚀", 2, 30, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "display_name" } };

-- test: trop court
RETURN fn::validation_display_name("J", 2, 30, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 2, length: 1 } };

-- test: chaîne blanche
RETURN fn::validation_display_name("  ", 2, 30, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_display_name(NONE, 2, 30, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_display_name(NULL, 2, 30, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_display_name(42, 2, 30, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_display_name("ab", 5, 2, false);
