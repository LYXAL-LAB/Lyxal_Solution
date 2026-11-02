-- lyxal-test: assertions
-- Tests de fn::validation_lyxal_module_name (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_lyxal_module_name(" Lyxal_Booking ", ["lyxal_"], 3, 64)
    == { valid: true, value: "lyxal_booking", code: NONE, details: {} };

-- test: préfixe non autorisé
RETURN fn::validation_lyxal_module_name("booking", ["lyxal_"], 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed_prefixes: ["lyxal_"] } };

-- test: tiret refusé
RETURN fn::validation_lyxal_module_name("lyxal-booking", ["lyxal_"], 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "snake_case" } };

-- test: chaîne blanche
RETURN fn::validation_lyxal_module_name("  ", ["lyxal_"], 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_lyxal_module_name(NONE, ["lyxal_"], 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_lyxal_module_name(NULL, ["lyxal_"], 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_lyxal_module_name(42, ["lyxal_"], 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_module_name("lyxal_a", [], 3, 64);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_lyxal_module_name("lyxal_a", NONE, 9, 3);
