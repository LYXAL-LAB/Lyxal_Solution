-- lyxal-test: assertions
-- Tests de fn::validation_allowed_types (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: type autorisé
RETURN fn::validation_allowed_types(5, ["int", "decimal"])
    == { valid: true, value: 5, code: NONE, details: {} };

-- test: type refusé
RETURN fn::validation_allowed_types("5", ["int", "Decimal"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: ["int", "decimal"], actual: "string" } };

-- test: valeur absente
RETURN fn::validation_allowed_types(NONE, ["int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_allowed_types(NULL, ["int"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_allowed_types(5, []);

-- test: type vide dans la liste
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_allowed_types(5, ["int", " "]);
