-- lyxal-test: assertions
-- Tests de fn::validation_array_of_strings (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: chaînes nettoyées
RETURN fn::validation_array_of_strings([" admin ", "user"], false, 1, 10)
    == { valid: true, value: ["admin", "user"], code: NONE, details: {} };

-- test: chaîne vide autorisée
RETURN fn::validation_array_of_strings(["  "], true, NONE, NONE)
    == { valid: true, value: [""], code: NONE, details: {} };

-- test: chaîne vide refusée
RETURN fn::validation_array_of_strings(["a", " "], false, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: { scope: "item" } };

-- test: chaîne trop courte
RETURN fn::validation_array_of_strings(["ab"], false, 3, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { scope: "item", min_length: 3 } };

-- test: chaîne trop longue
RETURN fn::validation_array_of_strings(["abcd"], false, NONE, 3)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { scope: "item", max_length: 3 } };

-- test: élément non chaîne
RETURN fn::validation_array_of_strings(["a", 1], true, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "string" } };

-- test: valeur absente
RETURN fn::validation_array_of_strings(NONE, true, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_array_of_strings(NULL, true, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type string refusé
RETURN fn::validation_array_of_strings("a", true, NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: "string" } };

-- test: borne négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_array_of_strings([], true, -1, NONE);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_array_of_strings([], true, 5, 2);
