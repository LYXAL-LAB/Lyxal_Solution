-- lyxal-test: assertions
-- Tests de fn::validation_surql_field_path (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_surql_field_path(" items[*].tags[0] ", true, true, 4)
    == { valid: true, value: "items[*].tags[0]", code: NONE, details: {} };

-- test: joker refusé
RETURN fn::validation_surql_field_path("items[*]", false, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_field_path" } };

-- test: index refusé
RETURN fn::validation_surql_field_path("items[0]", true, false, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_field_path" } };

-- test: trop de segments
RETURN fn::validation_surql_field_path("a.b.c.d.e", true, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_segments: 4, segments: 5 } };

-- test: segment vide
RETURN fn::validation_surql_field_path("a..b", true, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_field_path" } };

-- test: chaîne blanche
RETURN fn::validation_surql_field_path("  ", true, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_surql_field_path(NONE, true, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_surql_field_path(NULL, true, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_surql_field_path(42, true, true, 4)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: segments nuls
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_surql_field_path("a", true, true, 0);
