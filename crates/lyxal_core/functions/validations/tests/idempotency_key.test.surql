-- lyxal-test: assertions
-- Tests de fn::validation_idempotency_key (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_idempotency_key(" order:2026-0001 ", 8, 64)
    == { valid: true, value: "order:2026-0001", code: NONE, details: {} };

-- test: caractère interdit
RETURN fn::validation_idempotency_key("order 2026 0001", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "idempotency_key" } };

-- test: trop longue
RETURN fn::validation_idempotency_key("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 64, length: 65 } };

-- test: chaîne blanche
RETURN fn::validation_idempotency_key("  ", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_idempotency_key(NONE, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_idempotency_key(NULL, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_idempotency_key(42, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_idempotency_key("x", 9, 8);
