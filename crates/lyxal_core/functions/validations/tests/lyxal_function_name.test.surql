-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_function_name (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_lyxal_function_name(" Booking::Create ", true, 64)
    == { valid: true, value: "booking::create", code: NONE, details: {} };

-- test: espace de noms facultatif
RETURN fn::validation_lyxal_function_name("create", false, 64)
    == { valid: true, value: "create", code: NONE, details: {} };

-- test: sans espace de noms
RETURN fn::validation_lyxal_function_name("create", true, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_function_name", require_namespace: true } };

-- test: séparateur simple
RETURN fn::validation_lyxal_function_name("booking:create", true, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_function_name" } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_function_name("  ", true, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_function_name(NONE, true, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_function_name(NULL, true, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_function_name(42, true, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_function_name("a", true, 0);
