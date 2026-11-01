-- lyxal-test: assertions
-- Tests de fn::validation_surql_function (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur conforme
RETURN fn::validation_surql_function(" booking::create ", true, 3)
    == { valid: true, value: "booking::create", code: NONE, details: {} };

-- test: préfixe fn:: refusé
RETURN fn::validation_surql_function("fn::booking::create", true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_function" } };

-- test: sans espace de noms
RETURN fn::validation_surql_function("create", true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_function", require_namespace: true } };

-- test: trop de segments
RETURN fn::validation_surql_function("a::b::c::d", true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_segments: 3, segments: 4 } };

-- test: chaîne blanche
RETURN fn::validation_surql_function("  ", true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_surql_function(NONE, true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_surql_function(NULL, true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_surql_function(42, true, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: segments nuls
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_surql_function("a", false, 0);
