-- lyxal-test: assertions
-- Tests de fn::validation_nonce (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_nonce("a1B2c3D4e5", 8, 64)
    == { valid: true, value: "a1B2c3D4e5", code: NONE, details: {} };

-- test: caractère interdit
RETURN fn::validation_nonce("a1B2c3D4:e5", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "nonce" } };

-- test: trop court
RETURN fn::validation_nonce("abc", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 8, length: 3 } };

-- test: chaîne blanche
RETURN fn::validation_nonce("  ", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_nonce(NONE, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_nonce(NULL, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_nonce(42, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_nonce("x", 0, 8);
