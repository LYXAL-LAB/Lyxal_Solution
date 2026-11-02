-- lyxal-test: assertions
-- Tests de fn::validation_array_of_records (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: Record IDs de la bonne table
RETURN fn::validation_array_of_records([user:a, user:b], "user", false)
    == { valid: true, value: [user:a, user:b], code: NONE, details: {} };

-- test: toutes tables
RETURN fn::validation_array_of_records([user:a, team:b], NONE, false)
    == { valid: true, value: [user:a, team:b], code: NONE, details: {} };

-- test: autre table refusée
RETURN fn::validation_array_of_records([user:a, team:b], "user", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { scope: "item", allowed: ["user"] } };

-- test: enregistrement inexistant
RETURN fn::validation_array_of_records([lyxal_test_absent:x], NONE, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_FOUND", details: { scope: "item" } };

-- test: enregistrements existants
RETURN { UPSERT lyxal_test_ref:one SET code = "ONE"; RETURN fn::validation_array_of_records([lyxal_test_ref:one], "lyxal_test_ref", true).valid; };

-- test: élément non Record ID
RETURN fn::validation_array_of_records([user:a, "user:b"], NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "record" } };

-- test: valeur absente
RETURN fn::validation_array_of_records(NONE, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_of_records(NULL, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type record refusé
RETURN fn::validation_array_of_records(user:a, NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "record" } };

-- test: table attendue invalide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_array_of_records([], "user-x", false);
