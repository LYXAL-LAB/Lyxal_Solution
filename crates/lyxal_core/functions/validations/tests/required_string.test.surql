-- lyxal-test: assertions
-- Tests de fn::validation_required_string (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: espaces retirés
RETURN fn::validation_required_string("  Équipe commerciale  ", 1, 100)
    == { valid: true, value: "Équipe commerciale", code: NONE, details: {} };

-- test: sans bornes
RETURN fn::validation_required_string("a", NONE, NONE)
    == { valid: true, value: "a", code: NONE, details: {} };

-- test: chaîne blanche
RETURN fn::validation_required_string("   ", NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: trop courte (caractères Unicode)
RETURN fn::validation_required_string("été", 4, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 4, length: 3 } };

-- test: trop longue
RETURN fn::validation_required_string("abcdef", NONE, 5)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 5, length: 6 } };

-- test: valeur absente
RETURN fn::validation_required_string(NONE, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_required_string(NULL, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_required_string(12, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: borne négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_required_string("a", -1, NONE);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_required_string("a", 10, 2);
