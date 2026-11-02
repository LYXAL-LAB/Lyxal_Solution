-- lyxal-test: assertions
-- Tests de fn::validation_enum_any (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: entier autorisé
RETURN fn::validation_enum_any(2, [1, 2, 3])
    == { valid: true, value: 2, code: NONE, details: {} };

-- test: chaîne autorisée
RETURN fn::validation_enum_any("b", ["a", "b"])
    == { valid: true, value: "b", code: NONE, details: {} };

-- test: valeur refusée
RETURN fn::validation_enum_any(4, [1, 2, 3])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: [1, 2, 3] } };

-- test: aucune conversion de type
RETURN fn::validation_enum_any("2", [1, 2, 3]).code == "CORE_VALIDATION_NOT_ALLOWED";

-- test: valeur absente
RETURN fn::validation_enum_any(NONE, [1])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_enum_any(NULL, [1])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_enum_any(1, []);
