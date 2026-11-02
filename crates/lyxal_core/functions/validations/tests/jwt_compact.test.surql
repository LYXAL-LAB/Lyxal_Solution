-- lyxal-test: assertions
-- Tests de fn::validation_jwt_compact (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_jwt_compact("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl", 4096)
    == { valid: true, value: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0.c2lnbmF0dXJl", code: NONE, details: {} };

-- test: trop long
RETURN fn::validation_jwt_compact("a.b.c", 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 3, length: 5 } };

-- test: deux segments
RETURN fn::validation_jwt_compact("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIn0", 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "jwt_compact" } };

-- test: segment vide
RETURN fn::validation_jwt_compact("a..c", 4096).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_jwt_compact("  ", 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_jwt_compact(NONE, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_jwt_compact(NULL, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_jwt_compact(42, 4096)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur maximale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_jwt_compact("a.b.c", 0);
