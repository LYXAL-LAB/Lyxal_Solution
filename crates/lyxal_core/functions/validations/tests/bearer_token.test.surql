-- lyxal-test: assertions
-- Tests de fn::validation_bearer_token (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_bearer_token("Bearer abc.DEF-123_xyz", 8, 64)
    == { valid: true, value: "abc.DEF-123_xyz", code: NONE, details: {} };

-- test: sans préfixe Bearer
RETURN fn::validation_bearer_token("abc.DEF-123_xyz", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "bearer_token" } };

-- test: jeton invalide
RETURN fn::validation_bearer_token("Bearer abc def!", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "bearer_token" } };

-- test: jeton trop court
RETURN fn::validation_bearer_token("Bearer abc", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 8, length: 3 } };

-- test: chaîne blanche
RETURN fn::validation_bearer_token("  ", 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_bearer_token(NONE, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_bearer_token(NULL, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_bearer_token(42, 8, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_bearer_token("x", 0, 5);
