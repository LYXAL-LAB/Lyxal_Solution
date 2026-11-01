-- lyxal-test: assertions
-- Tests de fn::validation_bytes (format : crates/lyxal_core/implementation_plan.md §5).

-- test: octets dans les bornes
RETURN fn::validation_bytes(<bytes> "abc", 1, 10)
    == { valid: true, value: <bytes> "abc", code: NONE, details: {} };

-- test: trop court
RETURN fn::validation_bytes(<bytes> "abc", 4, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 4, length: 3 } };

-- test: trop long
RETURN fn::validation_bytes(<bytes> "abc", NONE, 2)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 2, length: 3 } };

-- test: valeur absente
RETURN fn::validation_bytes(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_bytes(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_bytes("abc", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "bytes", actual: "string" } };

-- test: borne négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_bytes(<bytes> "abc", -1, NONE);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_bytes(<bytes> "abc", 5, 2);
