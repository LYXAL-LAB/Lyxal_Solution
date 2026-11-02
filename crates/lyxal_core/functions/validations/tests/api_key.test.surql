-- lyxal-test: assertions
-- Tests de fn::validation_api_key (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_api_key("  sk_live_ABC123 ", 8, 64, ["sk_"])
    == { valid: true, value: "sk_live_ABC123", code: NONE, details: {} };

-- test: sans préfixe imposé
RETURN fn::validation_api_key("pk_ABCDEFGH", 8, 64, NONE)
    == { valid: true, value: "pk_ABCDEFGH", code: NONE, details: {} };

-- test: trop courte
RETURN fn::validation_api_key("sk_1", 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 8, length: 4 } };

-- test: caractère interdit
RETURN fn::validation_api_key("sk_live_AB C123", 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "api_key" } };

-- test: préfixe non autorisé
RETURN fn::validation_api_key("pk_live_ABC123", 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed_prefixes: ["sk_"] } };

-- test: chaîne blanche
RETURN fn::validation_api_key("  ", 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_api_key(NONE, 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_api_key(NULL, 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_api_key(42, 8, 64, ["sk_"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_api_key("x", 10, 5, NONE);

-- test: liste de préfixes vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_api_key("x", 1, 5, []);
