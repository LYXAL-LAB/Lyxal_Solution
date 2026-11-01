-- lyxal-test: assertions
-- Tests de fn::validation_initials (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_initials(" j. p. ", 1, 3)
    == { valid: true, value: "JP", code: NONE, details: {} };

-- test: chiffre
RETURN fn::validation_initials("J2", 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "initials" } };

-- test: trop d'initiales
RETURN fn::validation_initials("A.B.C.D", 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_count: 3, count: 4 } };

-- test: chaîne blanche
RETURN fn::validation_initials("  ", 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_initials(NONE, 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_initials(NULL, 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_initials(42, 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_initials("a", 3, 1);
