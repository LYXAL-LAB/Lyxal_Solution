-- lyxal-test: assertions
-- Tests de fn::validation_reserved_words (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: mot libre
RETURN fn::validation_reserved_words(" alice ", ["admin", "system"], true)
    == { valid: true, value: "alice", code: NONE, details: {} };

-- test: mot réservé, casse ignorée
RETURN fn::validation_reserved_words("System", ["admin", "system"], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };

-- test: espaces conservés
RETURN fn::validation_reserved_words(" admin", ["admin"], false)
    == { valid: true, value: " admin", code: NONE, details: {} };

-- test: valeur absente
RETURN fn::validation_reserved_words(NONE, ["a"], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_reserved_words(NULL, ["a"], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_reserved_words(1, ["a"], true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_reserved_words("abc", [], true);

-- test: mot vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_reserved_words("abc", [" "], true);
