-- lyxal-test: assertions
-- Tests de fn::validation_luhn (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_luhn(" 7992-7398 713 ", 8, 19)
    == { valid: true, value: "79927398713", code: NONE, details: {} };

-- test: clé fausse
RETURN fn::validation_luhn("79927398710", 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "luhn" } };

-- test: lettre
RETURN fn::validation_luhn("7992739871a", 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "digits" } };

-- test: trop court
RETURN fn::validation_luhn("1234567", 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 8, length: 7 } };

-- test: chaîne blanche
RETURN fn::validation_luhn("  ", 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_luhn(NONE, 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_luhn(NULL, 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_luhn(42, 8, 19)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_luhn("1", 10, 8);
