-- lyxal-test: assertions
-- Tests de fn::validation_surql_field (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_surql_field(" created_at ", false, 64)
    == { valid: true, value: "created_at", code: NONE, details: {} };

-- test: champ id autorisé
RETURN fn::validation_surql_field("id", true, 64)
    == { valid: true, value: "id", code: NONE, details: {} };

-- test: champ id refusé
RETURN fn::validation_surql_field("id", false, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };

-- test: point refusé
RETURN fn::validation_surql_field("a.b", false, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_identifier" } };

-- test: chaîne blanche
RETURN fn::validation_surql_field("  ", false, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_surql_field(NONE, false, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_surql_field(NULL, false, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_surql_field(42, false, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_surql_field("a", false, 0);
