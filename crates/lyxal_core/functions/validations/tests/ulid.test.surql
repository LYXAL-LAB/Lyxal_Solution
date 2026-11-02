-- lyxal-test: assertions
-- Tests de fn::validation_ulid (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: ULID nettoyé et mis en majuscules
RETURN fn::validation_ulid("  01arz3ndektsv4rrffq69g5fav ")
    == { valid: true, value: "01ARZ3NDEKTSV4RRFFQ69G5FAV", code: NONE, details: {} };

-- test: chaîne vide
RETURN fn::validation_ulid("   ")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: format invalide
RETURN fn::validation_ulid("01ARZ3NDEKTSV4RRFFQ69G5FA")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "ulid" } };

-- test: valeur absente
RETURN fn::validation_ulid(NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_ulid(NULL)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_ulid(12)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
