-- lyxal-test: assertions
-- Tests de fn::validation_contains (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: fragment présent
RETURN fn::validation_contains(" a@b ", ["@"], true, true)
    == { valid: true, value: "a@b", code: NONE, details: {} };

-- test: insensible à la casse
RETURN fn::validation_contains("Bonjour", ["JOUR"], false, false)
    == { valid: true, value: "Bonjour", code: NONE, details: {} };

-- test: sensible à la casse
RETURN fn::validation_contains("Bonjour", ["JOUR"], true, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { contains_any: ["JOUR"] } };

-- test: valeur absente
RETURN fn::validation_contains(NONE, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_contains(NULL, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_contains(1, ["a"], true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_contains("abc", [], true, true);

-- test: fragment vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_contains("abc", [" "], true, true);
