-- lyxal-test: assertions
-- Tests de fn::validation_regex (format : crates/lyxal_core/implementation_plan.md §5).

-- test: motif respecté
RETURN fn::validation_regex(" REF-000123 ", "^REF-[0-9]{6}$")
    == { valid: true, value: "REF-000123", code: NONE, details: {} };

-- test: motif non respecté
RETURN fn::validation_regex("REF-12", "^REF-[0-9]{6}$")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { pattern: "^REF-[0-9]{6}$" } };

-- test: chaîne blanche
RETURN fn::validation_regex("  ", "^a$")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_regex(NONE, "^a$")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_regex(NULL, "^a$")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_regex(1, "^a$")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: motif vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_regex("a", " ");
