-- lyxal-test: assertions
-- Tests de fn::validation_identifier (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: identifiant valide
RETURN fn::validation_identifier(" _user_id2 ", 1, 64)
    == { valid: true, value: "_user_id2", code: NONE, details: {} };

-- test: chiffre initial refusé
RETURN fn::validation_identifier("2user", 1, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "identifier" } };

-- test: tiret refusé
RETURN fn::validation_identifier("user-id", 1, 64).code == "CORE_VALIDATION_FORMAT";

-- test: trop court
RETURN fn::validation_identifier("ab", 3, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: 3, length: 2 } };

-- test: trop long
RETURN fn::validation_identifier("abcd", 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 3, length: 4 } };

-- test: chaîne blanche
RETURN fn::validation_identifier("  ", 1, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_identifier(NONE, 1, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_identifier(NULL, 1, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_identifier(1, 1, 64)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: longueur minimale nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_identifier("a", 0, 5);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_identifier("a", 5, 2);
