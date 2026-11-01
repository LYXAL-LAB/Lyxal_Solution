-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_database (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_lyxal_database(" Main_DB2 ", 2, 64)
    == { valid: true, value: "main_db2", code: NONE, details: {} };

-- test: souligné final
RETURN fn::validation_lyxal_database("main_", 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_database" } };

-- test: souligné doublé
RETURN fn::validation_lyxal_database("main__db", 2, 64).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_lyxal_database("  ", 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_database(NONE, 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_database(NULL, 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_database(42, 2, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_database("ab", 5, 2);
