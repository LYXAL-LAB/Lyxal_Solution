-- lyxal-test: assertions
-- Tests de fn::validation_weekday (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: lundi
RETURN fn::validation_weekday(1, NONE)
    == { valid: true, value: 1, code: NONE, details: {} };

-- test: jour autorisé
RETURN fn::validation_weekday(5, [1, 2, 3, 4, 5])
    == { valid: true, value: 5, code: NONE, details: {} };

-- test: jour non autorisé
RETURN fn::validation_weekday(6, [1, 2, 3, 4, 5])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: [1, 2, 3, 4, 5] } };

-- test: zéro
RETURN fn::validation_weekday(0, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1 } };

-- test: huit
RETURN fn::validation_weekday(8, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 7 } };

-- test: valeur absente
RETURN fn::validation_weekday(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_weekday(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_weekday("lundi", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: "string" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_weekday(1, []);

-- test: jour hors de 1 à 7 dans la liste
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_weekday(1, [1, 9]);
