-- lyxal-test: assertions
-- Tests de fn::validation_snake_case_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_snake_case_name(" Send_Invoice_V2 ", 3, 30)
    == { valid: true, value: "send_invoice_v2", code: NONE, details: {} };

-- test: tiret refusé
RETURN fn::validation_snake_case_name("send-invoice", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "snake_case" } };

-- test: chiffre initial
RETURN fn::validation_snake_case_name("2send", 3, 30).code == "CORE_VALIDATION_FORMAT";

-- test: trop court
RETURN fn::validation_snake_case_name("ab", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 3, length: 2 } };

-- test: chaîne blanche
RETURN fn::validation_snake_case_name("  ", 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_snake_case_name(NONE, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_snake_case_name(NULL, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_snake_case_name(42, 3, 30)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_snake_case_name("abc", 5, 3);
