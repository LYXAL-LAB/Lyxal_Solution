-- lyxal-test: assertions
-- Tests de fn::validation_starts_with (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: préfixe présent
RETURN fn::validation_starts_with("sk_live_1", ["pk_", "sk_"], true, true)
    == { valid: true, value: "sk_live_1", code: NONE, details: {} };

-- test: insensible à la casse
RETURN fn::validation_starts_with("SK_1", ["sk_"], false, true)
    == { valid: true, value: "SK_1", code: NONE, details: {} };

-- test: préfixe absent
RETURN fn::validation_starts_with("live_sk_1", ["sk_"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { starts_with_any: ["sk_"] } };

-- test: valeur absente
RETURN fn::validation_starts_with(NONE, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_starts_with(NULL, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_starts_with(1, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_starts_with("abc", [], true, true);

-- test: préfixe vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_starts_with("abc", [""], true, true);
