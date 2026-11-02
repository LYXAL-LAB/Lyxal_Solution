-- lyxal-test: assertions
-- Tests de fn::validation_recovery_code (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_recovery_code(" ab12-cd34-ef56 ", 3, 4)
    == { valid: true, value: "AB12-CD34-EF56", code: NONE, details: {} };

-- test: groupe trop court
RETURN fn::validation_recovery_code("AB12-CD3-EF56", 3, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "recovery_code", group_count: 3, group_length: 4 } };

-- test: nombre de groupes incorrect
RETURN fn::validation_recovery_code("AB12-CD34", 3, 4).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_recovery_code("  ", 3, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_recovery_code(NONE, 3, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_recovery_code(NULL, 3, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_recovery_code(42, 3, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: forme nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_recovery_code("x", 0, 4);
